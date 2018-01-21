module Keisan
  class Parser
    KEYWORDS = %w(let puts).freeze

    attr_reader :tokens, :components

    def initialize(string: nil, tokens: nil)
      if string.nil? && tokens.nil?
        raise Exceptions::InternalError.new("Invalid arguments")
      end

      if !string.nil?
        @tokens = Tokenizer.new(string).tokens
      else
        raise Exceptions::InternalError.new("Invalid argument: tokens = #{tokens}") if tokens.nil? || !tokens.is_a?(Array)
        @tokens = tokens
      end

      @components = []

      if multi_line?
        parse_multi_line!
      elsif @tokens.first&.is_a?(Tokens::Word) && KEYWORDS.include?(@tokens.first.string)
        parse_keyword!
      else
        parse_components!
        remove_unary_identity!
      end
    end

    def ast
      @ast ||= AST::Builder.new(parser: self).ast
    end

    private

    def multi_line?
      @tokens.any? {|token| token.is_a?(Tokens::LineSeparator)}
    end

    def parse_multi_line!
      line_parsers = @tokens.split {|token| token.is_a?(Tokens::LineSeparator)}.map {|tokens| self.class.new(tokens: tokens)}
      @components = []
      line_parsers.each.with_index do |line_parser, i|
        @components += line_parser.components
        if i < line_parsers.count - 1
          @components << Parsing::LineSeparator.new
        end
      end
    end

    def parse_keyword!
      keyword = tokens.first.string
      arguments = if tokens[1].is_a?(Tokens::Group)
                    tokens[1].sub_tokens.split {|token| token.is_a?(Tokens::Comma)}.map {|argument_tokens|
                      Parsing::Argument.new(argument_tokens)
                    }
                  else
                    Parsing::Argument.new(tokens[1..-1])
                  end
      @components = [
        Parsing::Function.new(keyword, arguments)
      ]
    end

    def parse_components!
      @unparsed_tokens = tokens.dup

      # Components will store the elements (numbers, variables, bracket components, function calls)
      # and the operators in between
      while @unparsed_tokens.count > 0
        token = @unparsed_tokens.shift
        add_token_to_components!(token)
      end
    end

    def remove_unary_identity!
      @components = @components.select do |component|
        !component.is_a?(Parsing::Operator) || !(component.node_class <= AST::UnaryIdentity)
      end
    end

    def is_start_of_line?
      @components.empty? || @components.last.is_a?(Parsing::LineSeparator)
    end

    # Elements are groups of tokens separated by (non-unary) operators
    # The following are basic elements:
    # number
    # variable
    # function (word + round group)
    # list (square group)
    #
    # Additionally these can be modified by having any number of unary operators in front,
    # and any number of indexing groups (square groups) at the back
    #
    def add_token_to_components!(token)
      if token.is_a?(Tokens::LineSeparator)
        @components << Parsing::LineSeparator.new
      elsif is_start_of_line? || @components[-1].is_a?(Parsing::Operator)
        # Expect an element or a unary operator
        if token.type == :operator
          # Here it must be a unary operator
          add_unary_operator_to_components!(token)
        else
          # Here it must be an element
          add_element_to_components!(token)
        end

      elsif @components[-1].is_a?(Parsing::Element)
        # A word followed by a "round group" is actually a function: e.g. sin(x)
        if @components[-1].is_a?(Parsing::Variable) && token.type == :group && token.group_type == :round
          add_function_to_components!(token)
        # Here it is a postfix Indexing (access elements by index)
        elsif token.type == :group && token.group_type == :square
          add_indexing_to_components!(token)
        elsif token.type == :dot
          @components << Parsing::Dot.new
        elsif token.type == :operator
          add_operator_to_components!(token)
        else
          # Concatenation is multiplication
          @components << Parsing::Times.new
          add_token_to_components!(token)
        end

      elsif @components[-1].is_a?(Parsing::Dot)
        # Expect a word
        case token.type
        when :word
          @components[-1] = Parsing::DotWord.new(token.string)
        else
          raise Exceptions::ParseError.new("A word must follow a dot, received #{token.string}")
        end

      elsif @components[-1].is_a?(Parsing::DotWord)
        add_token_after_dot_word!(token)

      else
        raise Exceptions::ParseError.new("Token cannot be parsed, #{token.string}")
      end
    end

    def add_token_after_dot_word!(token)
      case token.type
      when :group
        case token.group_type
        when :round
          # Here it is a method call
          name = @components[-1].name
          @components[-1] = Parsing::DotOperator.new(name, arguments_from_group(token))
        when :square
          # Here we are indexing after method call
          add_indexing_to_components!(token)
        else
          raise Exceptions::ParseError.new("Cannot take curly braces after function call")
        end
      when :dot
        # Chaining method calls
        @components << Parsing::Dot.new
      when :operator
        # End of method call, move on to operator
        add_operator_to_components!(token)
      else
        raise Exceptions::ParseError.new("Expected arguments to dot operator, received #{token.string}")
      end
    end

    def add_unary_operator_to_components!(token)
      case token.operator_type
      when :+
        @components << Parsing::UnaryPlus.new
      when :-
        @components << Parsing::UnaryMinus.new
      when :"~"
        @components << Parsing::BitwiseNot.new
      when :"~~"
        @components << Parsing::BitwiseNotNot.new
      when :"!"
        @components << Parsing::LogicalNot.new
      when :"!!"
        @components << Parsing::LogicalNotNot.new
      else
        raise Exceptions::ParseError.new("Unhandled unary operator type #{token.operator_type}")
      end
    end

    def add_element_to_components!(token)
      case token
      when Tokens::Number
        @components << Parsing::Number.new(token.value)
      when Tokens::String
        @components << Parsing::String.new(token.value)
      when Tokens::Null
        @components << Parsing::Null.new
      when Tokens::Word
        @components << Parsing::Variable.new(token.string)
      when Tokens::Boolean
        @components << Parsing::Boolean.new(token.value)
      when Tokens::Group
        add_group_element_components!(token)
      else
        raise Exceptions::ParseError.new("Unhandled operator type #{token.operator_type}")
      end
    end

    def add_group_element_components!(token)
      case token.group_type
      when :round
        @components << Parsing::RoundGroup.new(token.sub_tokens)
      when :square
        @components << Parsing::List.new(arguments_from_group(token))
      when :curly
        if token.sub_tokens.any? {|token| token.is_a?(Tokens::Colon)}
          @components << Parsing::Hash.new(token.sub_tokens.split {|token| token.is_a?(Tokens::Comma)})
        else
          @components << Parsing::CurlyGroup.new(token.sub_tokens)
        end
      else
        raise Exceptions::ParseError.new("Unhandled group type #{token.group_type}")
      end
    end

    def add_operator_to_components!(token)
      case token.operator_type
      # Assignment
      when :"="
        add_assignment_to_components!(token)
      else
        @components << operator_to_component(token.operator_type)
      end
    end

    OPERATOR_TO_PARSING_CLASS = {
      :+    => Parsing::Plus,
      :-    => Parsing::Minus,
      :*    => Parsing::Times,
      :/    => Parsing::Divide,
      :**   => Parsing::Exponent,
      :%    => Parsing::Modulo,
      :"&"  => Parsing::BitwiseAnd,
      :"|"  => Parsing::BitwiseOr,
      :"^"  => Parsing::BitwiseXor,
      :"==" => Parsing::LogicalEqual,
      :"!=" => Parsing::LogicalNotEqual,
      :"&&" => Parsing::LogicalAnd,
      :"||" => Parsing::LogicalOr,
      :">"  => Parsing::LogicalGreaterThan,
      :"<"  => Parsing::LogicalLessThan,
      :">=" => Parsing::LogicalGreaterThanOrEqualTo,
      :"<=" => Parsing::LogicalLessThanOrEqualTo
    }.freeze

    def operator_to_component(operator)
      if klass = OPERATOR_TO_PARSING_CLASS[operator]
        klass.new
      else
        raise Exceptions::ParseError.new("Unhandled operator type #{operator}")
      end
    end

    def add_assignment_to_components!(token)
      if compound_operator = token.compound_operator
        @components << Parsing::CompoundAssignment.new(compound_operator)
      else
        @components << Parsing::Assignment.new
      end
    end

    def add_function_to_components!(token)
      @components[-1] = Parsing::Function.new(@components[-1].name, arguments_from_group(token))
    end

    def add_indexing_to_components!(token)
      # Have an indexing
      @components << Parsing::Indexing.new(arguments_from_group(token))
    end

    def arguments_from_group(token)
      if token.sub_tokens.empty?
        []
      else
        token.sub_tokens.split {|sub_token| sub_token.is_a?(Tokens::Comma)}.map do |sub_tokens|
          Parsing::Argument.new(sub_tokens)
        end
      end
    end
  end
end

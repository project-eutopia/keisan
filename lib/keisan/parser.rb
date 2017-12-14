module Keisan
  class Parser
    KEYWORDS = %w(let).freeze

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
          @components << Keisan::Parsing::LineSeparator.new
        end
      end
    end

    def parse_keyword!
      keyword = tokens.first.string
      @components = [
        Parsing::Function.new(keyword, Parsing::Argument.new(tokens[1..-1]))
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
      @components.empty? || @components.last.is_a?(Keisan::Parsing::LineSeparator)
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
        @components << Keisan::Parsing::LineSeparator.new
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
        else
          # Expect an operator
          raise Exceptions::ParseError.new("Expected an operator, received #{token.string}") unless token.type == :operator
          add_operator_to_components!(token)
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
        # Expect a round group
        if token.type == :group && token.group_type == :round
          name = @components[-1].name
          @components[-1] = Parsing::DotOperator.new(name, arguments_from_group(token))
        # Or indexing
        elsif token.type == :group && token.group_type == :square
          add_indexing_to_components!(token)
        # Or another operation
        elsif token.type == :dot
          @components << Keisan::Parsing::Dot.new
        # Or an operator
        elsif token.type == :operator
          add_operator_to_components!(token)
        else
          raise Exceptions::ParseError.new("Expected arguments to dot operator, received #{token.string}")
        end
      else
        raise Exceptions::ParseError.new("Token cannot be parsed, #{token.string}")
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
        case token.group_type
        when :round
          @components << Parsing::RoundGroup.new(token.sub_tokens)
        when :square
          @components << Parsing::List.new(arguments_from_group(token))
        when :curly
          @components << Parsing::CurlyGroup.new(token.sub_tokens)
        else
          raise Exceptions::ParseError.new("Unhandled group type #{token.group_type}")
        end
      else
        raise Exceptions::ParseError.new("Unhandled operator type #{token.operator_type}")
      end
    end

    def add_operator_to_components!(token)
      case token.operator_type
      # Assignment
      when :"="
        @components << Parsing::Assignment.new
      # Arithmetic
      when :+
        @components << Parsing::Plus.new
      when :-
        @components << Parsing::Minus.new
      when :*
        @components << Parsing::Times.new
      when :/
        @components << Parsing::Divide.new
      when :**
        @components << Parsing::Exponent.new
      when :%
        @components << Parsing::Modulo.new
      # Bitwise
      when :"&"
        @components << Parsing::BitwiseAnd.new
      when :"|"
        @components << Parsing::BitwiseOr.new
      when :"^"
        @components << Parsing::BitwiseXor.new
      # Logical
      when :"=="
        @components << Parsing::LogicalEqual.new
      when :"!="
        @components << Parsing::LogicalNotEqual.new
      when :"&&"
        @components << Parsing::LogicalAnd.new
      when :"||"
        @components << Parsing::LogicalOr.new
      when :">"
        @components << Parsing::LogicalGreaterThan.new
      when :"<"
        @components << Parsing::LogicalLessThan.new
      when :">="
        @components << Parsing::LogicalGreaterThanOrEqualTo.new
      when :"<="
        @components << Parsing::LogicalLessThanOrEqualTo.new
      else
        raise Exceptions::ParseError.new("Unhandled operator type #{token.operator_type}")
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

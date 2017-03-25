module Keisan
  class Parser
    attr_reader :tokens, :components

    def initialize(string: nil, tokens: nil)
      if string.nil? && tokens.nil?
        raise Keisan::Exceptions::InternalError.new("Invalid arguments")
      end

      if !string.nil?
        @tokens = Tokenizer.new(string).tokens
      else
        raise Keisan::Exceptions::InternalError.new("Invalid argument: tokens = #{tokens}") if tokens.nil? || !tokens.is_a?(Array)
        @tokens = tokens
      end

      @components = []

      parse_components!
    end

    def ast
      @ast ||= Keisan::AST::Builder.new(parser: self).ast
    end

    private

    def parse_components!
      @unparsed_tokens = tokens.dup

      # Components will store the elements (numbers, variables, bracket components, function calls)
      # and the operators in between
      while @unparsed_tokens.count > 0
        token = @unparsed_tokens.shift
        add_token_to_components!(token)
      end
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
      if @components.empty? || @components[-1].is_a?(Parsing::Operator)
        # Expect an element or a unary operator
        if token.type == :operator
          # Here it must be a unary operator
          add_unary_operator_to_components!(token)
        else
          # Here it must be an element
          add_element_to_components!(token)
        end

      elsif @components[-1].is_a?(Parsing::UnaryOperator)
        # Expect an element
        case token.type
        when :number, :string, :word, :group, :null, :boolean
          add_element_to_components!(token)
        else
          raise Keisan::Exceptions::ParseError.new("Expected an element, received #{token.string}")
        end

      elsif @components[-1].is_a?(Parsing::Element)
        # A word followed by a "round group" is actually a function: e.g. sin(x)
        if @components[-1].is_a?(Parsing::Variable) && token.type == :group && token.group_type == :round
          add_function_to_components!(token)
        # Here it is a postfix Indexing (access elements by index)
        elsif token.type == :group && token.group_type == :square
          add_indexing_to_components!(token)
        elsif token.type == :dot
          @components << Keisan::Parsing::Dot.new
        else
          # Expect an operator
          raise Keisan::Exceptions::ParseError.new("Expected an operator, received #{token.string}") unless token.type == :operator
          add_operator_to_components!(token)
        end

      elsif @components[-1].is_a?(Parsing::Dot)
        # Expect a word
        case token.type
        when :word
          @components[-1] = Parsing::DotWord.new(token.string)
        else
          raise Keisan::Exceptions::ParseError.new("A word must follow a dot, received #{token.string}")
        end

      elsif @components[-1].is_a?(Parsing::DotWord)
        # Expect a round group
        if token.type == :group && token.group_type == :round
          name = @components[-1].name
          @components[-1] = Parsing::DotOperator.new(name, arguments_from_group(token))
        elsif token.type == :dot
          @components << Keisan::Parsing::Dot.new
        elsif token.type == :group && token.group_type == :square
          add_indexing_to_components!(token)
        else
          raise Keisan::Exceptions::ParseError.new("Expected arguments to dot operator, received #{token.string}")
        end
      else
        raise Keisan::Exceptions::ParseError.new("Token cannot be parsed, #{token.string}")
      end
    end

    def add_unary_operator_to_components!(token)
      case token.operator_type
      when :+
        @components << Keisan::Parsing::UnaryPlus.new
      when :-
        @components << Keisan::Parsing::UnaryMinus.new
      when :"~"
        @components << Keisan::Parsing::BitwiseNot.new
      when :"~~"
        @components << Keisan::Parsing::BitwiseNotNot.new
      when :"!"
        @components << Keisan::Parsing::LogicalNot.new
      when :"!!"
        @components << Keisan::Parsing::LogicalNotNot.new
      else
        raise Keisan::Exceptions::ParseError.new("Unhandled unary operator type #{token.operator_type}")
      end
    end

    def add_element_to_components!(token)
      case token
      when Keisan::Tokens::Number
        @components << Keisan::Parsing::Number.new(token.value)
      when Keisan::Tokens::String
        @components << Keisan::Parsing::String.new(token.value)
      when Keisan::Tokens::Null
        @components << Keisan::Parsing::Null.new
      when Keisan::Tokens::Word
        @components << Keisan::Parsing::Variable.new(token.string)
      when Keisan::Tokens::Boolean
        @components << Keisan::Parsing::Boolean.new(token.value)
      when Keisan::Tokens::Group
        case token.group_type
        when :round
          @components << Keisan::Parsing::RoundGroup.new(token.sub_tokens)
        when :square
          @components << Parsing::List.new(arguments_from_group(token))
        else
          raise Keisan::Exceptions::ParseError.new("Unhandled group type #{token.group_type}")
        end
      else
        raise Keisan::Exceptions::ParseError.new("Unhandled operator type #{token.operator_type}")
      end
    end

    def add_operator_to_components!(token)
      case token.operator_type
      # Arithmetic
      when :+
        @components << Keisan::Parsing::Plus.new
      when :-
        @components << Keisan::Parsing::Minus.new
      when :*
        @components << Keisan::Parsing::Times.new
      when :/
        @components << Keisan::Parsing::Divide.new
      when :**
        @components << Keisan::Parsing::Exponent.new
      # Bitwise
      when :"&"
        @components << Keisan::Parsing::BitwiseAnd.new
      when :"|"
        @components << Keisan::Parsing::BitwiseOr.new
      when :"^"
        @components << Keisan::Parsing::BitwiseXor.new
      when :"~"
        @components << Keisan::Parsing::BitwiseNot.new
      when :"~~"
        @components << Keisan::Parsing::BitwiseNotNot.new
      # Logical
      when :"&&"
        @components << Keisan::Parsing::LogicalAnd.new
      when :"||"
        @components << Keisan::Parsing::LogicalOr.new
      when :"!"
        @components << Keisan::Parsing::LogicalNot.new
      when :"!!"
        @components << Keisan::Parsing::LogicalNotNot.new
      when :">"
        @components << Keisan::Parsing::LogicalGreaterThan.new
      when :"<"
        @components << Keisan::Parsing::LogicalLessThan.new
      when :">="
        @components << Keisan::Parsing::LogicalGreaterThanOrEqualTo.new
      when :"<="
        @components << Keisan::Parsing::LogicalLessThanOrEqualTo.new
      else
        raise Keisan::Exceptions::ParseError.new("Unhandled operator type #{token.operator_type}")
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
        token.sub_tokens.split {|sub_token| sub_token.is_a?(Keisan::Tokens::Comma)}.map do |sub_tokens|
          Parsing::Argument.new(sub_tokens)
        end
      end
    end
  end
end

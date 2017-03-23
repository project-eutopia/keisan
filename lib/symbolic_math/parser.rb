module SymbolicMath
  class Parser
    attr_reader :tokens, :components

    def initialize(string: nil, tokens: nil)
      if string.nil? && tokens.nil?
        raise SymbolicMath::Exceptions::InternalError.new("Invalid arguments")
      end

      if string.present?
        @tokens = Tokenizer.new(string).tokens
      else
        raise SymbolicMath::Exceptions::InternalError.new("Invalid argument: tokens = #{tokens}") if tokens.nil? || !tokens.is_a?(Array)
        @tokens = tokens
      end

      @components = []

      parse_components!
    end

    def ast
      @ast ||= SymbolicMath::AST::Builder.new(parser: self).ast
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
        if token.type != :number && token.type != :word && token.type != :group
          raise SymbolicMath::Exceptions::ParseError.new("Expected an element, received #{token.string}")
        end
        add_element_to_components!(token)

      elsif @components[-1].is_a?(Parsing::Element)
        if @components[-1].is_a?(Parsing::Variable) && token.type == :group
          # Have a function actually, not a variable
          @components[-1] = Parsing::Function.new(
            @components[-1].name,
            token.sub_tokens.split {|sub_token| sub_token.is_a?(SymbolicMath::Tokens::Comma)}.map do |sub_tokens|
              Parsing::Argument.new(sub_tokens)
            end
          )
        else
          # Expect an operator
          raise SymbolicMath::Exceptions::ParseError.new("Expected an operator, received #{token.string}") unless token.type == :operator
          add_operator_to_components!(token)
        end

      else
        raise SymbolicMath::Exceptions::InternalError.new("Invalid parsing!")
      end
    end

    def add_unary_operator_to_components!(token)
      case token.operator_type
      when :+
        @components << SymbolicMath::Parsing::UnaryPlus.new
      when :-
        @components << SymbolicMath::Parsing::UnaryMinus.new
      when :"~"
        @components << SymbolicMath::Parsing::BitwiseNot.new
      when :"~~"
        @components << SymbolicMath::Parsing::BitwiseNotNot.new
      when :"!"
        @components << SymbolicMath::Parsing::LogicalNot.new
      when :"!!"
        @components << SymbolicMath::Parsing::LogicalNotNot.new
      else
        raise SymbolicMath::Exceptions::ParseError.new("Unhandled unary operator type #{token.operator_type}")
      end
    end

    def add_element_to_components!(token)
      case token
      when SymbolicMath::Tokens::Number
        @components << SymbolicMath::Parsing::Number.new(token.value)
      when SymbolicMath::Tokens::Word
        case token.string.downcase
        when "true"
          @components << SymbolicMath::Parsing::Boolean.new(true)
        when "false"
          @components << SymbolicMath::Parsing::Boolean.new(false)
        else
          @components << SymbolicMath::Parsing::Variable.new(token.string)
        end
      when SymbolicMath::Tokens::Group
        @components << SymbolicMath::Parsing::Group.new(token.sub_tokens)
      else
        raise SymbolicMath::Exceptions::ParseError.new("Unhandled operator type #{token.operator_type}")
      end
    end

    def add_operator_to_components!(token)
      case token.operator_type
      # Arithmetic
      when :+
        @components << SymbolicMath::Parsing::Plus.new
      when :-
        @components << SymbolicMath::Parsing::Minus.new
      when :*
        @components << SymbolicMath::Parsing::Times.new
      when :/
        @components << SymbolicMath::Parsing::Divide.new
      when :^
        @components << SymbolicMath::Parsing::Exponent.new
      # Bitwise
      when :"&"
        @components << SymbolicMath::Parsing::BitwiseAnd.new
      when :"|"
        @components << SymbolicMath::Parsing::BitwiseOr.new
      when :"^"
        @components << SymbolicMath::Parsing::BitwiseXor.new
      when :"~"
        @components << SymbolicMath::Parsing::BitwiseNot.new
      when :"~~"
        @components << SymbolicMath::Parsing::BitwiseNotNot.new
      # Logical
      when :"&&"
        @components << SymbolicMath::Parsing::LogicalAnd.new
      when :"||"
        @components << SymbolicMath::Parsing::LogicalOr.new
      when :"!"
        @components << SymbolicMath::Parsing::LogicalNot.new
      when :"!!"
        @components << SymbolicMath::Parsing::LogicalNotNot.new
      when :">"
        @components << SymbolicMath::Parsing::LogicalGreaterThan.new
      when :"<"
        @components << SymbolicMath::Parsing::LogicalLessThan.new
      when :">="
        @components << SymbolicMath::Parsing::LogicalGreaterThanOrEqualTo.new
      when :"<="
        @components << SymbolicMath::Parsing::LogicalLessThanOrEqualTo.new
      else
        raise SymbolicMath::Exceptions::ParseError.new("Unhandled operator type #{token.operator_type}")
      end
    end
  end
end

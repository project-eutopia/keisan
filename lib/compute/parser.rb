module Compute
  class Parser
    attr_reader :tokens, :components

    def initialize(string: nil, tokens: nil)
      if string.nil? && tokens.nil?
        raise Compute::Exceptions::InternalError.new("Invalid arguments")
      end

      if string.present?
        @tokens = Tokenizer.new(string).tokens
      else
        raise Compute::Exceptions::InternalError.new("Invalid argument: tokens = #{tokens}") if tokens.nil? || !tokens.is_a?(Array)
        @tokens = tokens
      end

      @components = []

      parse_components!
    end

    def ast
      @ast ||= Compute::AST::Builder.new(parser: self).ast
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
        when :number, :string, :word, :group
          add_element_to_components!(token)
        else
          raise Compute::Exceptions::ParseError.new("Expected an element, received #{token.string}")
        end

      elsif @components[-1].is_a?(Parsing::Element)
        if @components[-1].is_a?(Parsing::Variable) && token.type == :group && token.group_type == :round
          add_function_to_components!(token)
        elsif token.type == :group && token.group_type == :square
          add_indexing_to_components!(token)
        else
          # Expect an operator
          raise Compute::Exceptions::ParseError.new("Expected an operator, received #{token.string}") unless token.type == :operator
          add_operator_to_components!(token)
        end

      else
        raise Compute::Exceptions::InternalError.new("Invalid parsing!")
      end
    end

    def add_unary_operator_to_components!(token)
      case token.operator_type
      when :+
        @components << Compute::Parsing::UnaryPlus.new
      when :-
        @components << Compute::Parsing::UnaryMinus.new
      when :"~"
        @components << Compute::Parsing::BitwiseNot.new
      when :"~~"
        @components << Compute::Parsing::BitwiseNotNot.new
      when :"!"
        @components << Compute::Parsing::LogicalNot.new
      when :"!!"
        @components << Compute::Parsing::LogicalNotNot.new
      else
        raise Compute::Exceptions::ParseError.new("Unhandled unary operator type #{token.operator_type}")
      end
    end

    def add_element_to_components!(token)
      case token
      when Compute::Tokens::Number
        @components << Compute::Parsing::Number.new(token.value)
      when Compute::Tokens::String
        @components << Compute::Parsing::String.new(token.value)
      when Compute::Tokens::Null
        @components << Compute::Parsing::Null.new
      when Compute::Tokens::Word
        case token.string.downcase
        when "true"
          @components << Compute::Parsing::Boolean.new(true)
        when "false"
          @components << Compute::Parsing::Boolean.new(false)
        else
          @components << Compute::Parsing::Variable.new(token.string)
        end
      when Compute::Tokens::Group
        case token.group_type
        when :round
          @components << Compute::Parsing::RoundGroup.new(token.sub_tokens)
        when :square
          @components << if token.sub_tokens.empty?
                           Parsing::List.new([])
                         else
                           Parsing::List.new(
                             token.sub_tokens.split {|sub_token| sub_token.is_a?(Compute::Tokens::Comma)}.map do |sub_tokens|
                               Parsing::Argument.new(sub_tokens)
                             end
                           )
                         end
        else
          raise Compute::Exceptions::ParseError.new("Unhandled group type #{token.group_type}")
        end
      else
        raise Compute::Exceptions::ParseError.new("Unhandled operator type #{token.operator_type}")
      end
    end

    def add_operator_to_components!(token)
      case token.operator_type
      # Arithmetic
      when :+
        @components << Compute::Parsing::Plus.new
      when :-
        @components << Compute::Parsing::Minus.new
      when :*
        @components << Compute::Parsing::Times.new
      when :/
        @components << Compute::Parsing::Divide.new
      when :**
        @components << Compute::Parsing::Exponent.new
      # Bitwise
      when :"&"
        @components << Compute::Parsing::BitwiseAnd.new
      when :"|"
        @components << Compute::Parsing::BitwiseOr.new
      when :"^"
        @components << Compute::Parsing::BitwiseXor.new
      when :"~"
        @components << Compute::Parsing::BitwiseNot.new
      when :"~~"
        @components << Compute::Parsing::BitwiseNotNot.new
      # Logical
      when :"&&"
        @components << Compute::Parsing::LogicalAnd.new
      when :"||"
        @components << Compute::Parsing::LogicalOr.new
      when :"!"
        @components << Compute::Parsing::LogicalNot.new
      when :"!!"
        @components << Compute::Parsing::LogicalNotNot.new
      when :">"
        @components << Compute::Parsing::LogicalGreaterThan.new
      when :"<"
        @components << Compute::Parsing::LogicalLessThan.new
      when :">="
        @components << Compute::Parsing::LogicalGreaterThanOrEqualTo.new
      when :"<="
        @components << Compute::Parsing::LogicalLessThanOrEqualTo.new
      else
        raise Compute::Exceptions::ParseError.new("Unhandled operator type #{token.operator_type}")
      end
    end

    def add_function_to_components!(token)
      # Have a function actually, not a variable
      if token.sub_tokens.empty?
        @components[-1] = Parsing::Function.new(@components[-1].name, [])
      else
        @components[-1] = Parsing::Function.new(
          @components[-1].name,
          token.sub_tokens.split {|sub_token| sub_token.is_a?(Compute::Tokens::Comma)}.map do |sub_tokens|
            Parsing::Argument.new(sub_tokens)
          end
        )
      end
    end

    def add_indexing_to_components!(token)
      # Have an indexing
      @components << if token.sub_tokens.empty?
                       Parsing::Indexing.new([])
                     else
                       Parsing::Indexing.new(
                         token.sub_tokens.split {|sub_token| sub_token.is_a?(Compute::Tokens::Comma)}.map do |sub_tokens|
                           Parsing::Argument.new(sub_tokens)
                         end
                       )
                     end
    end
  end
end

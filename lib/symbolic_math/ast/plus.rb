module SymbolicMath
  module AST
    class Plus < ArithmeticOperator
      def initialize(children = [], parsing_operators = [])
        super
        convert_minus_to_plus!
      end

      def self.priority
        10
      end

      def arity
        2..Float::INFINITY
      end

      def symbol
        :+
      end

      def blank_value
        0
      end

      private

      def convert_minus_to_plus!
        @parsing_operators.each.with_index do |parsing_operator, index|
          if parsing_operator.is_a?(SymbolicMath::Parsing::Minus)
            @children[index+1] = SymbolicMath::AST::UnaryMinus.new(@children[index+1])
          end
        end
      end
    end
  end
end

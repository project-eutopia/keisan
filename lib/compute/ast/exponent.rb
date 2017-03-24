module Compute
  module AST
    class Exponent < ArithmeticOperator
      def self.priority
        30
      end

      def arity
        (2..2)
      end

      def associativity
        :right
      end

      def symbol
        :**
      end

      def blank_value
        1
      end
    end
  end
end

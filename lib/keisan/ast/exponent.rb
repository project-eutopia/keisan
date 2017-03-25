module Keisan
  module AST
    class Exponent < ArithmeticOperator
      def arity
        (2..2)
      end

      def associativity
        :right
      end

      def self.symbol
        :**
      end

      def blank_value
        1
      end
    end
  end
end

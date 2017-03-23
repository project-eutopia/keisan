module SymbolicMath
  module AST
    class BitwiseOr < BitwiseOperator
      def self.priority
        11
      end

      def arity
        2..Float::INFINITY
      end

      def symbol
        :"|"
      end

      def blank_value
        0
      end
    end
  end
end

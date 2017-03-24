module Keisan
  module AST
    class BitwiseXor < BitwiseOperator
      def self.priority
        21
      end

      def arity
        2..Float::INFINITY
      end

      def symbol
        :"^"
      end

      def blank_value
        0
      end
    end
  end
end

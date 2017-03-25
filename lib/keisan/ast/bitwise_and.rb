module Keisan
  module AST
    class BitwiseAnd < BitwiseOperator
      def arity
        2..Float::INFINITY
      end

      def self.symbol
        :"&"
      end

      def blank_value
        ~0
      end
    end
  end
end

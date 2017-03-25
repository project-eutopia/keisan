module Keisan
  module AST
    class UnaryBitwiseNot < UnaryOperator
      def value(context = nil)
        return ~child.value(context)
      end

      def self.symbol
        :"~"
      end
    end
  end
end

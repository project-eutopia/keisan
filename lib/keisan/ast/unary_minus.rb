module Keisan
  module AST
    class UnaryMinus < UnaryOperator
      def value(context = nil)
        return -1 * child.value(context)
      end

      def self.symbol
        :"-"
      end
    end
  end
end

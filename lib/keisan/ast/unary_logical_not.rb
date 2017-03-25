module Keisan
  module AST
    class UnaryLogicalNot < UnaryOperator
      def value(context = nil)
        return !child.value(context)
      end

      def self.symbol
        :"!"
      end
    end
  end
end

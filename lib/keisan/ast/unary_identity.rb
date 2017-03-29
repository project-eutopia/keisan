module Keisan
  module AST
    class UnaryIdentity < UnaryOperator
      def value(context = nil)
        return child.value(context)
      end

      def self.symbol
        nil
      end

      def simplify(context = nil)
        child.simplify(context)
      end
    end
  end
end

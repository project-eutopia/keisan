module Keisan
  module AST
    class UnaryPlus < UnaryIdentity
      def value(context = nil)
        return children.first.value(context)
      end

      def self.symbol
        :"+"
      end
    end
  end
end

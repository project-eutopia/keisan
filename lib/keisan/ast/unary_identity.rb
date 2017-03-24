module Keisan
  module AST
    class UnaryIdentity < UnaryOperator
      def value(context = nil)
        return children.first.value(context)
      end
    end
  end
end

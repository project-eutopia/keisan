module Keisan
  module AST
    class UnaryIdentity < UnaryOperator
      def value(context = nil)
        return child.value(context)
      end

      def to_s
        child.to_s
      end
    end
  end
end

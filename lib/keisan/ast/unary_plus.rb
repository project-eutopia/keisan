module Keisan
  module AST
    class UnaryPlus < UnaryOperator
      def value(context = nil)
        return children.first.value(context)
      end

      def to_s
        child.to_s
      end
    end
  end
end

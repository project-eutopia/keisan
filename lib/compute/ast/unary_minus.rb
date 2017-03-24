module Compute
  module AST
    class UnaryMinus < UnaryOperator
      def value(context = nil)
        return -1 * children.first.value(context)
      end
    end
  end
end

module Compute
  module AST
    class UnaryInverse < UnaryOperator
      def value(context = nil)
        return Rational(1, children.first.value(context))
      end
    end
  end
end

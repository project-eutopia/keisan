module SymbolicMath
  module AST
    class UnaryPlus < UnaryOperator
      def value(context = nil)
        return children.first.value(context)
      end
    end
  end
end

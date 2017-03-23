module SymbolicMath
  module AST
    class UnaryLogicalNot < UnaryOperator
      def value(context = nil)
        return !children.first.value(context)
      end
    end
  end
end

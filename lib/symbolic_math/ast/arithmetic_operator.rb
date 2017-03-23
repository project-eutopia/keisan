module SymbolicMath
  module AST
    class ArithmeticOperator < Operator
      def associativity
        :left
      end
    end
  end
end

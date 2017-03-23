module SymbolicMath
  module AST
    class BitwiseOperator < Operator
      def associativity
        :left
      end
    end
  end
end

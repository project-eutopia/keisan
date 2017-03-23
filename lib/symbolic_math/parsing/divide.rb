module SymbolicMath
  module Parsing
    class Divide < ArithmeticOperator
      def node_class
        SymbolicMath::AST::Times
      end
    end
  end
end

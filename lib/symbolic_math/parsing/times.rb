module SymbolicMath
  module Parsing
    class Times < ArithmeticOperator
      def node_class
        SymbolicMath::AST::Times
      end
    end
  end
end

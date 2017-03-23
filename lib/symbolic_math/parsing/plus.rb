module SymbolicMath
  module Parsing
    class Plus < ArithmeticOperator
      def node_class
        SymbolicMath::AST::Plus
      end
    end
  end
end

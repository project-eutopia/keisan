module SymbolicMath
  module Parsing
    class Minus < ArithmeticOperator
      def node_class
        SymbolicMath::AST::Plus
      end
    end
  end
end

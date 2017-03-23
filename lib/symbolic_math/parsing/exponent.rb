module SymbolicMath
  module Parsing
    class Exponent < ArithmeticOperator
      def node_class
        SymbolicMath::AST::Exponent
      end
    end
  end
end

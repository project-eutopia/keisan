module SymbolicMath
  module Parsing
    class LogicalNotNot < LogicalOperator
      def node_class
        SymbolicMath::AST::UnaryIdentity
      end
    end
  end
end

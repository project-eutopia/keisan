module SymbolicMath
  module Parsing
    class LogicalNot < LogicalOperator
      def node_class
        SymbolicMath::AST::UnaryLogicalNot
      end
    end
  end
end

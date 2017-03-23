module SymbolicMath
  module Parsing
    class LogicalAnd < LogicalOperator
      def node_class
        SymbolicMath::AST::LogicalAnd
      end
    end
  end
end

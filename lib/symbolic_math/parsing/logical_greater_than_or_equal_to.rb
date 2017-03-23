module SymbolicMath
  module Parsing
    class LogicalGreaterThanOrEqualTo < LogicalOperator
      def node_class
        SymbolicMath::AST::LogicalGreaterThanOrEqualTo
      end
    end
  end
end

module SymbolicMath
  module Parsing
    class LogicalLessThanOrEqualTo < LogicalOperator
      def node_class
        SymbolicMath::AST::LogicalLessThanOrEqualTo
      end
    end
  end
end

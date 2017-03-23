module SymbolicMath
  module Parsing
    class LogicalGreaterThan < LogicalOperator
      def node_class
        SymbolicMath::AST::LogicalGreaterThan
      end
    end
  end
end

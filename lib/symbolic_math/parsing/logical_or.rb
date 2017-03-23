module SymbolicMath
  module Parsing
    class LogicalOr < LogicalOperator
      def node_class
        SymbolicMath::AST::LogicalOr
      end
    end
  end
end

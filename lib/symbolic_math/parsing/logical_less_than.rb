module SymbolicMath
  module Parsing
    class LogicalLessThan < LogicalOperator
      def node_class
        SymbolicMath::AST::LogicalLessThan
      end
    end
  end
end

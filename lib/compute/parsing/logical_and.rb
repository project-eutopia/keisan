module Compute
  module Parsing
    class LogicalAnd < LogicalOperator
      def node_class
        Compute::AST::LogicalAnd
      end
    end
  end
end

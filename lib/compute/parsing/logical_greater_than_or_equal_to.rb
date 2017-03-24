module Compute
  module Parsing
    class LogicalGreaterThanOrEqualTo < LogicalOperator
      def node_class
        Compute::AST::LogicalGreaterThanOrEqualTo
      end
    end
  end
end

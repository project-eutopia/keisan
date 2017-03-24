module Compute
  module Parsing
    class LogicalGreaterThan < LogicalOperator
      def node_class
        Compute::AST::LogicalGreaterThan
      end
    end
  end
end

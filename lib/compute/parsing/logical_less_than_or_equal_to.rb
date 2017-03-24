module Compute
  module Parsing
    class LogicalLessThanOrEqualTo < LogicalOperator
      def node_class
        Compute::AST::LogicalLessThanOrEqualTo
      end
    end
  end
end

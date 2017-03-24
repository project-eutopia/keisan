module Compute
  module Parsing
    class LogicalOr < LogicalOperator
      def node_class
        Compute::AST::LogicalOr
      end
    end
  end
end

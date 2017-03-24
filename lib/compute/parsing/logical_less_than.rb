module Compute
  module Parsing
    class LogicalLessThan < LogicalOperator
      def node_class
        Compute::AST::LogicalLessThan
      end
    end
  end
end

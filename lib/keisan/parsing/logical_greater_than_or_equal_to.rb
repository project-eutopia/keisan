module Keisan
  module Parsing
    class LogicalGreaterThanOrEqualTo < LogicalOperator
      def node_class
        AST::LogicalGreaterThanOrEqualTo
      end
    end
  end
end

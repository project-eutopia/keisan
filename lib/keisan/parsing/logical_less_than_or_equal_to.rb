module Keisan
  module Parsing
    class LogicalLessThanOrEqualTo < LogicalOperator
      def node_class
        AST::LogicalLessThanOrEqualTo
      end
    end
  end
end

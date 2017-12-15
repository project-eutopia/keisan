module Keisan
  module Parsing
    class LogicalGreaterThan < LogicalOperator
      def node_class
        AST::LogicalGreaterThan
      end
    end
  end
end

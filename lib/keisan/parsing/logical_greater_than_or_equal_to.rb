module Keisan
  module Parsing
    class LogicalGreaterThanOrEqualTo < LogicalOperator
      def node_class
        Keisan::AST::LogicalGreaterThanOrEqualTo
      end
    end
  end
end

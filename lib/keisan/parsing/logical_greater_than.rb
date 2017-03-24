module Keisan
  module Parsing
    class LogicalGreaterThan < LogicalOperator
      def node_class
        Keisan::AST::LogicalGreaterThan
      end
    end
  end
end

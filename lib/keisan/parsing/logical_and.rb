module Keisan
  module Parsing
    class LogicalAnd < LogicalOperator
      def node_class
        AST::LogicalAnd
      end
    end
  end
end

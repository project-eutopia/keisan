module Keisan
  module Parsing
    class LogicalOr < LogicalOperator
      def node_class
        AST::LogicalOr
      end
    end
  end
end

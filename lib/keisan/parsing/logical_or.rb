module Keisan
  module Parsing
    class LogicalOr < LogicalOperator
      def node_class
        Keisan::AST::LogicalOr
      end
    end
  end
end

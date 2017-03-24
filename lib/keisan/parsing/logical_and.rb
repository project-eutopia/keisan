module Keisan
  module Parsing
    class LogicalAnd < LogicalOperator
      def node_class
        Keisan::AST::LogicalAnd
      end
    end
  end
end

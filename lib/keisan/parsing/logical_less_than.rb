module Keisan
  module Parsing
    class LogicalLessThan < LogicalOperator
      def node_class
        AST::LogicalLessThan
      end
    end
  end
end

module Keisan
  module Parsing
    class LogicalLessThanOrEqualTo < LogicalOperator
      def node_class
        Keisan::AST::LogicalLessThanOrEqualTo
      end
    end
  end
end

module Keisan
  module Parsing
    class LogicalLessThan < LogicalOperator
      def node_class
        Keisan::AST::LogicalLessThan
      end
    end
  end
end

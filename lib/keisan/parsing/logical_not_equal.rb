module Keisan
  module Parsing
    class LogicalNotEqual < LogicalOperator
      def node_class
        AST::LogicalNotEqual
      end
    end
  end
end

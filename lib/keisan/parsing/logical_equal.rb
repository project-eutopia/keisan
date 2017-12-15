module Keisan
  module Parsing
    class LogicalEqual < LogicalOperator
      def node_class
        AST::LogicalEqual
      end
    end
  end
end

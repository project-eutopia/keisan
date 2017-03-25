module Keisan
  module Parsing
    class LogicalNotEqual < LogicalOperator
      def node_class
        Keisan::AST::LogicalNotEqual
      end
    end
  end
end

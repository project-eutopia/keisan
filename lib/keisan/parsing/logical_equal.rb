module Keisan
  module Parsing
    class LogicalEqual < LogicalOperator
      def node_class
        Keisan::AST::LogicalEqual
      end
    end
  end
end

module Keisan
  module Parsing
    class LogicalNot < UnaryOperator
      def node_class
        AST::UnaryLogicalNot
      end
    end
  end
end

module Keisan
  module Parsing
    class LogicalNotNot < UnaryOperator
      def node_class
        AST::UnaryIdentity
      end
    end
  end
end

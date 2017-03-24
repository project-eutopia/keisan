module Keisan
  module Parsing
    class LogicalNot < UnaryOperator
      def node_class
        Keisan::AST::UnaryLogicalNot
      end
    end
  end
end

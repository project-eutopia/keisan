module Compute
  module Parsing
    class LogicalNot < UnaryOperator
      def node_class
        Compute::AST::UnaryLogicalNot
      end
    end
  end
end

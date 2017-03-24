module Compute
  module Parsing
    class LogicalNotNot < UnaryOperator
      def node_class
        Compute::AST::UnaryIdentity
      end
    end
  end
end

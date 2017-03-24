module Compute
  module Parsing
    class BitwiseNotNot < UnaryOperator
      def node_class
        Compute::AST::UnaryIdentity
      end
    end
  end
end

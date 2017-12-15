module Keisan
  module Parsing
    class BitwiseNotNot < UnaryOperator
      def node_class
        AST::UnaryIdentity
      end
    end
  end
end

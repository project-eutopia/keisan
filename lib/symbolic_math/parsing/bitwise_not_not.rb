module SymbolicMath
  module Parsing
    class BitwiseNotNot < UnaryOperator
      def node_class
        SymbolicMath::AST::UnaryIdentity
      end
    end
  end
end

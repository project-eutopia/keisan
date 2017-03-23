module SymbolicMath
  module Parsing
    class BitwiseNotNot < BitwiseOperator
      def node_class
        SymbolicMath::AST::UnaryIdentity
      end
    end
  end
end

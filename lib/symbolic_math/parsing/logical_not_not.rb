module SymbolicMath
  module Parsing
    class LogicalNotNot < UnaryOperator
      def node_class
        SymbolicMath::AST::UnaryIdentity
      end
    end
  end
end

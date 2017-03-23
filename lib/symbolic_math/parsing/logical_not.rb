module SymbolicMath
  module Parsing
    class LogicalNot < UnaryOperator
      def node_class
        SymbolicMath::AST::UnaryLogicalNot
      end
    end
  end
end

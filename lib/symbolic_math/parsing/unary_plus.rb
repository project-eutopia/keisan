module SymbolicMath
  module Parsing
    class UnaryPlus < UnaryOperator
      def node_class
        SymbolicMath::AST::UnaryPlus
      end
    end
  end
end

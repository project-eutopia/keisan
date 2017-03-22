module SymbolicMath
  module Parsing
    class UnaryMinus < UnaryOperator
      def node_class
        SymbolicMath::AST::UnaryMinus
      end
    end
  end
end

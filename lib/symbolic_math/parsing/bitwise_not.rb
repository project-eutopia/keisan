module SymbolicMath
  module Parsing
    class BitwiseNot < UnaryOperator
      def node_class
        SymbolicMath::AST::UnaryBitwiseNot
      end
    end
  end
end

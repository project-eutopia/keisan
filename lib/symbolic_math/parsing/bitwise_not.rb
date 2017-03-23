module SymbolicMath
  module Parsing
    class BitwiseNot < BitwiseOperator
      def node_class
        SymbolicMath::AST::UnaryBitwiseNot
      end
    end
  end
end

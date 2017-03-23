module SymbolicMath
  module Parsing
    class BitwiseAnd < BitwiseOperator
      def node_class
        SymbolicMath::AST::BitwiseAnd
      end
    end
  end
end

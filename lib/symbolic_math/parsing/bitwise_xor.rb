module SymbolicMath
  module Parsing
    class BitwiseXor < BitwiseOperator
      def node_class
        SymbolicMath::AST::BitwiseXor
      end
    end
  end
end

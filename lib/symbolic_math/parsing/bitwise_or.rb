module SymbolicMath
  module Parsing
    class BitwiseOr < BitwiseOperator
      def node_class
        SymbolicMath::AST::BitwiseOr
      end
    end
  end
end

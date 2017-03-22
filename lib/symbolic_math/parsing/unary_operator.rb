module SymbolicMath
  module Parsing
    class UnaryOperator < Group
      def priority
        SymbolicMath::AST::Times.priority
      end
    end
  end
end

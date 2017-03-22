module SymbolicMath
  module Parsing
    class UnaryOperator < Component
      def priority
        SymbolicMath::AST::Times.priority
      end
    end
  end
end

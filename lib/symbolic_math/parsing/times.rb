module SymbolicMath
  module Parsing
    class Times < Operator
      def priority
        SymbolicMath::AST::Times.priority
      end
    end
  end
end

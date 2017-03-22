module SymbolicMath
  module Parsing
    class Divide < Operator
      def priority
        SymbolicMath::AST::Times.priority
      end
    end
  end
end

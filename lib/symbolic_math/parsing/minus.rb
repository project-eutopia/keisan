module SymbolicMath
  module Parsing
    class Minus < Operator
      def priority
        SymbolicMath::AST::Plus.priority
      end
    end
  end
end

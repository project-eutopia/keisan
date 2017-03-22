module SymbolicMath
  module Parsing
    class Plus < Operator
      def priority
        SymbolicMath::AST::Plus.priority
      end
    end
  end
end

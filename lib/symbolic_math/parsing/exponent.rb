module SymbolicMath
  module Parsing
    class Exponent < Operator
      def priority
        SymbolicMath::AST::Exponent.priority
      end
    end
  end
end

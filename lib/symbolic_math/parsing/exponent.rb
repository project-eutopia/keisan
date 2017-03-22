module SymbolicMath
  module Parsing
    class Exponent < Operator
      def priority
        node_class.priority
      end

      def node_class
        SymbolicMath::AST::Exponent
      end
    end
  end
end

module SymbolicMath
  module Parsing
    class Times < Operator
      def priority
        node_class.priority
      end

      def node_class
        SymbolicMath::AST::Times
      end
    end
  end
end

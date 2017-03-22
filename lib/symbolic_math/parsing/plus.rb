module SymbolicMath
  module Parsing
    class Plus < Operator
      def priority
        node_class.priority
      end

      def node_class
        SymbolicMath::AST::Plus
      end
    end
  end
end

module SymbolicMath
  module Parsing
    class Indexing < SquareGroup
      attr_reader :arguments
      def initialize(arguments)
        @arguments = arguments
      end

      def node_class
        SymbolicMath::AST::Indexing
      end
    end
  end
end

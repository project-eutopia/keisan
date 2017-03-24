module SymbolicMath
  module Parsing
    class Indexing < SquareGroup
      attr_reader :arguments
      def initialize(arguments)
        @arguments = arguments
      end
    end
  end
end

module SymbolicMath
  module Parsing
    class List < SquareGroup
      attr_reader :elements
      def initialize(elements)
        @elements = elements
      end
    end
  end
end

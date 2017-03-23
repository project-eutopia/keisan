module SymbolicMath
  module Parsing
    class String < Element
      attr_reader :value
      def initialize(value)
        @value = value
      end
    end
  end
end

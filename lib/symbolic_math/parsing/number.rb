module SymbolicMath
  module Parsing
    class Number < Element
      attr_reader :value
      def initialize(value)
        @value = value
      end
    end
  end
end

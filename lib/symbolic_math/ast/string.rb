module SymbolicMath
  module AST
    class String < Literal
      attr_reader :value

      def initialize(value)
        @value = value
      end

      def value(context = nil)
        value
      end
    end
  end
end

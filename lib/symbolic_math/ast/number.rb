module SymbolicMath
  module AST
    class Number < Literal
      attr_reader :number

      def initialize(number)
        @number = number
      end

      def value(context = nil)
        number
      end
    end
  end
end

module Keisan
  module AST
    class Number < ConstantLiteral
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

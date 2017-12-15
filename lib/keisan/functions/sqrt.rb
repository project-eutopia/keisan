module Keisan
  module Functions
    class Sqrt < CMathFunction
      def initialize
        super("sqrt")
      end

      protected

      def self.derivative(argument)
        AST::Exponent.new([argument, Rational(-1,2)]) / 2
      end
    end
  end
end

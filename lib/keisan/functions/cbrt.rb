module Keisan
  module Functions
    class Cbrt < CMathFunction
      def initialize
        super("cbrt")
      end

      protected

      def self.derivative(argument)
        AST::Exponent.new([argument, Rational(-2,3)]) / 3
      end
    end
  end
end

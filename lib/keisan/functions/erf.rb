module Keisan
  module Functions
    class Erf < MathFunction
      def initialize
        super("erf")
      end

      protected

      def self.derivative(argument)
        2/Math.sqrt(Math::PI) * AST::Function.new([-argument**2], "exp")
      end
    end
  end
end

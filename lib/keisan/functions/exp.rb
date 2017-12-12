module Keisan
  module Functions
    class Exp < MathFunction
      def initialize
        super("exp")
      end

      protected

      def self.derivative(argument)
        Keisan::AST::Function.new([argument], "exp")
      end
    end
  end
end

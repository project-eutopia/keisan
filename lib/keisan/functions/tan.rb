module Keisan
  module Functions
    class Tan < MathFunction
      def initialize
        super("tan")
      end

      protected

      def self.derivative(argument)
        Keisan::AST::Exponent.new([Keisan::AST::Function.new([argument], "cos"), -2])
      end
    end
  end
end

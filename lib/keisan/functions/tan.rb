module Keisan
  module Functions
    class Tan < MathFunction
      def initialize
        super("tan")
      end

      protected

      def self.derivative(argument_simplified, argument_differentiated)
        argument_differentiated * Keisan::AST::Exponent.new([Keisan::AST::Function.new([argument_simplified], "cos"), -2])
      end
    end
  end
end

module Keisan
  module Functions
    class Exp < MathFunction
      def initialize
        super("exp")
      end

      protected

      def self.derivative(argument_simplified, argument_differentiated)
        argument_differentiated * Keisan::AST::Function.new([argument_simplified], "exp")
      end
    end
  end
end

module Keisan
  module Functions
    class Cos < MathFunction
      def initialize
        super("cos")
      end

      protected

      def self.derivative(argument_simplified, argument_differentiated)
        -argument_differentiated * Keisan::AST::Function.new([argument_simplified], "sin")
      end
    end
  end
end

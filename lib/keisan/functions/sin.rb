module Keisan
  module Functions
    class Sin < MathFunction
      def initialize
        super("sin")
      end

      protected

      def self.derivative(argument_simplified, argument_differentiated)
        argument_differentiated * Keisan::AST::Function.new([argument_simplified], "cos")
      end
    end
  end
end

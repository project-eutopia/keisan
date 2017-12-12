module Keisan
  module Functions
    class Sin < MathFunction
      def initialize
        super("sin")
      end

      protected

      def self.derivative(argument)
        Keisan::AST::Function.new([argument], "cos")
      end
    end
  end
end

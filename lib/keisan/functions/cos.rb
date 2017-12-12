module Keisan
  module Functions
    class Cos < MathFunction
      def initialize
        super("cos")
      end

      protected

      def self.derivative(argument)
        -Keisan::AST::Function.new([argument], "sin")
      end
    end
  end
end

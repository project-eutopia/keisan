module Keisan
  module Functions
    class Tan < CMathFunction
      def initialize
        super("tan")
      end

      protected

      def self.derivative(argument)
        AST::Exponent.new([AST::Function.new([argument], "cos"), -2])
      end
    end
  end
end

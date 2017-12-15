module Keisan
  module Functions
    class Tanh < CMathFunction
      def initialize
        super("tanh")
      end

      protected

      def self.derivative(argument)
        AST::Exponent.new([AST::Function.new([argument], "cosh"), -2])
      end
    end
  end
end

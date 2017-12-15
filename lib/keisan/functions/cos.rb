module Keisan
  module Functions
    class Cos < CMathFunction
      def initialize
        super("cos")
      end

      protected

      def self.derivative(argument)
        -AST::Function.new([argument], "sin")
      end
    end
  end
end

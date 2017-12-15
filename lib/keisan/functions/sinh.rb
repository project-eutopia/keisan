module Keisan
  module Functions
    class Sinh < CMathFunction
      def initialize
        super("sinh")
      end

      protected

      def self.derivative(argument)
        AST::Function.new([argument], "cosh")
      end
    end
  end
end

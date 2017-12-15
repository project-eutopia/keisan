module Keisan
  module Functions
    class Cosh < CMathFunction
      def initialize
        super("cosh")
      end

      protected

      def self.derivative(argument)
        AST::Function.new([argument], "sinh")
      end
    end
  end
end

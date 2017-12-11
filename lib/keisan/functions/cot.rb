module Keisan
  module Functions
    class Cot < MathFunction
      def initialize
        super("cot", Proc.new {|arg| 1 / Math::tan(arg)})
      end

      protected

      def self.derivative(argument_simplified, argument_differentiated)
        -argument_differentiated * Keisan::AST::Exponent.new([Keisan::AST::Function.new([argument_simplified], "sin"), -2])
      end
    end
  end
end

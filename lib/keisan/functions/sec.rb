module Keisan
  module Functions
    class Sec < MathFunction
      def initialize
        super("sec", Proc.new {|arg| 1 / Math::cos(arg)})
      end

      protected

      def self.derivative(argument_simplified, argument_differentiated)
        argument_differentiated * Keisan::AST::Function.new([argument_simplified], "sin") * Keisan::AST::Exponent.new([Keisan::AST::Function.new([argument_simplified], "cos"), -2])
      end
    end
  end
end

module Keisan
  module Functions
    class Csc < MathFunction
      def initialize
        super("csc", Proc.new {|arg| 1 / Math::sin(arg)})
      end

      protected

      def self.derivative(argument_simplified, argument_differentiated)
        -argument_differentiated * Keisan::AST::Function.new([argument_simplified], "cos") * Keisan::AST::Exponent.new([Keisan::AST::Function.new([argument_simplified], "sin"), -2])
      end
    end
  end
end

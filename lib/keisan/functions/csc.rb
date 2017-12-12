module Keisan
  module Functions
    class Csc < MathFunction
      def initialize
        super("csc", Proc.new {|arg| 1 / Math::sin(arg)})
      end

      protected

      def self.derivative(argument)
        -Keisan::AST::Function.new([argument], "cos") * Keisan::AST::Exponent.new([Keisan::AST::Function.new([argument], "sin"), -2])
      end
    end
  end
end

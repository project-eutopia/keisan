module Keisan
  module Functions
    class Sec < CMathFunction
      def initialize
        super("sec", Proc.new {|arg| 1 / CMath::cos(arg)})
      end

      protected

      def self.derivative(argument)
        Keisan::AST::Function.new([argument], "sin") * Keisan::AST::Exponent.new([Keisan::AST::Function.new([argument], "cos"), -2])
      end
    end
  end
end

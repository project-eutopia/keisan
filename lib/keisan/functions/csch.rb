module Keisan
  module Functions
    class Csch < CMathFunction
      def initialize
        super("csch", Proc.new {|arg| 1 / CMath::sinh(arg)})
      end

      protected

      def self.derivative(argument)
        -Keisan::AST::Function.new([argument], "cosh") * Keisan::AST::Exponent.new([Keisan::AST::Function.new([argument], "sinh"), -2])
      end
    end
  end
end

module Keisan
  module Functions
    class Csch < CMathFunction
      def initialize
        super("csch", Proc.new {|arg| 1 / CMath::sinh(arg)})
      end

      protected

      def self.derivative(argument)
        -AST::Function.new([argument], "cosh") * AST::Exponent.new([AST::Function.new([argument], "sinh"), -2])
      end
    end
  end
end

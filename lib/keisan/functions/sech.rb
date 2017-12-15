module Keisan
  module Functions
    class Sech < CMathFunction
      def initialize
        super("sech", Proc.new {|arg| 1 / CMath::cosh(arg)})
      end

      protected

      def self.derivative(argument)
        -AST::Function.new([argument], "sinh") * AST::Exponent.new([AST::Function.new([argument], "cosh"), -2])
      end
    end
  end
end

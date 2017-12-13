module Keisan
  module Functions
    class Sech < CMathFunction
      def initialize
        super("sech", Proc.new {|arg| 1 / CMath::cosh(arg)})
      end

      protected

      def self.derivative(argument)
        -Keisan::AST::Function.new([argument], "sinh") * Keisan::AST::Exponent.new([Keisan::AST::Function.new([argument], "cosh"), -2])
      end
    end
  end
end

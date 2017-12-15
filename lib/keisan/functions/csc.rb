module Keisan
  module Functions
    class Csc < CMathFunction
      def initialize
        super("csc", Proc.new {|arg| 1 / CMath::sin(arg)})
      end

      protected

      def self.derivative(argument)
        -AST::Function.new([argument], "cos") * AST::Exponent.new([AST::Function.new([argument], "sin"), -2])
      end
    end
  end
end

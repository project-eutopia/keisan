module Keisan
  module Functions
    class Cot < CMathFunction
      def initialize
        super("cot", Proc.new {|arg| 1 / CMath::tan(arg)})
      end

      protected

      def self.derivative(argument)
        -Keisan::AST::Exponent.new([Keisan::AST::Function.new([argument], "sin"), -2])
      end
    end
  end
end

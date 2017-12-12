module Keisan
  module Functions
    class Log < MathFunction
      def initialize
        super("log")
      end

      protected

      def self.derivative(argument)
        1 / argument
      end
    end
  end
end

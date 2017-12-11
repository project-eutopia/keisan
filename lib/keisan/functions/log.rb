module Keisan
  module Functions
    class Log < MathFunction
      def initialize
        super("log")
      end

      protected

      def self.derivative(argument_simplified, argument_differentiated)
        argument_differentiated / argument_simplified
      end
    end
  end
end

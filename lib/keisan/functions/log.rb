module Keisan
  module Functions
    class Log < CMathFunction
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

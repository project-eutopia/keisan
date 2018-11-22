require_relative "date_time_methods"

module Keisan
  module AST
    class Time < ConstantLiteral
      include DateTimeMethods

      attr_reader :time

      def initialize(time)
        @time = time
      end

      def value(context = nil)
        time
      end

      def to_s
        value.strftime("%Y-%m-%d %H:%M:%S")
      end
    end
  end
end

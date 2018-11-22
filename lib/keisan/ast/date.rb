require_relative "date_time_methods"

module Keisan
  module AST
    class Date < ConstantLiteral
      include DateTimeMethods

      attr_reader :date

      def initialize(date)
        @date = date
      end

      def value(context = nil)
        date
      end

      def to_s
        value.to_s
      end
    end
  end
end

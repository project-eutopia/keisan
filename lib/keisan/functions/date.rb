require "date"

module Keisan
  module Functions
    class Date < ProcFunction
      def initialize
        @name = "sample"
        @arity = ::Range.new(1, 3)
      end

      def call(context, *args)
        AST::Date.new(::Date.new(*args))
      end
    end
  end
end

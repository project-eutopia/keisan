require "time"

module Keisan
  module Functions
    class Time < ProcFunction
      def initialize
        @name = "time"
        @arity = ::Range.new(1, 7)
      end

      def call(context, *args)
        if args.count == 1 && args.first.is_a?(::String)
          AST::Time.new(::Time.parse(args.first))
        else
          AST::Time.new(::Time.new(*args))
        end
      end
    end
  end
end

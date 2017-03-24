module Keisan
  module Functions
    class Rand < Keisan::Function
      def initialize
        @name = "rand"
      end

      # Single argument: integer in range [0, max)
      # Double argument: integer in range [min, max)
      def call(context, *args)
        case args.size
        when 1
          context.random.rand(args.first)
        when 2
          context.random.rand(args.first...args.last)
        else
          raise Keisan::Exceptions::InvalidFunctionError.new
        end
      end
    end
  end
end

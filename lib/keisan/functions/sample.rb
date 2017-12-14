module Keisan
  module Functions
    class Sample < ProcFunction
      def initialize
        @name = "sample"
        @arity = 1
      end

      # Single argument: integer in range [0, max)
      # Double argument: integer in range [min, max)
      def call(context, *args)
        case args.size
        when 1
          args.first.sample(random: context.random)
        else
          raise Exceptions::InvalidFunctionError.new
        end
      end
    end
  end
end

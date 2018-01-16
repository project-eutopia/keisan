module Keisan
  module Functions
    class Sample < ProcFunction
      def initialize
        @name = "sample"
        @arity = ::Range.new(1, 2)
      end

      # Single argument: list to sample element from
      # Double argument: list and number of elements to sample
      def call(context, *args)
        case args.size
        when 1
          args.first.sample(random: context.random)
        when 2
          args[0].sample(args[1], random: context.random)
        else
          raise Exceptions::InvalidFunctionError.new
        end
      end
    end
  end
end

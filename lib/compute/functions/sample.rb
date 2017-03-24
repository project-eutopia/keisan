module Compute
  module Functions
    class Sample < Compute::Function
      def initialize
        @name = "sample"
      end

      # Single argument: integer in range [0, max)
      # Double argument: integer in range [min, max)
      def call(context, *args)
        case args.size
        when 1
          args.first.sample(random: context.random)
        else
          raise Compute::Exceptions::InvalidFunctionError.new
        end
      end
    end
  end
end

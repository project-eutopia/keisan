module Keisan
  module Functions
    class Sample < Keisan::Function
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
          raise Keisan::Exceptions::InvalidFunctionError.new
        end
      end
    end
  end
end

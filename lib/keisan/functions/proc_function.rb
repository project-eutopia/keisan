module Keisan
  module Functions
    class ProcFunction < Function
      def initialize(name, function_proc)
        raise Keisan::Exceptions::InvalidFunctionError.new unless function_proc.is_a?(Proc)

        super(name)
        @function_proc = function_proc
      end

      def call(context, *args)
        @function_proc.call(*args)
      end
    end
  end
end

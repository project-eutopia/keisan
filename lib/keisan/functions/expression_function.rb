module Keisan
  module Functions
    class ExpressionFunction < Keisan::Function
      attr_reader :arguments, :expression

      def initialize(name, arguments, expression, local_context)
        super(name)
        @expression = expression.deep_dup
        @arguments = arguments
        @local_context = local_context
      end

      def call(context, *args)
        unless @arguments.count == args.count
          raise Keisan::Exceptions::InvalidFunctionError.new("Invalid number of arguments for #{name} function")
        end

        local = @local_context.spawn_child
        arguments.each.with_index do |arg_name, i|
          local.register_variable!(arg_name, args[i])
        end

        expression.value(local)
      end
    end
  end
end

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

      def value(ast_function, context = nil)
        context ||= Keisan::Context.new
        argument_values = ast_function.children.map {|child| child.value(context)}
        call(context, *argument_values)
      end

      def evaluate(ast_function, context = nil)
        if ast_function.children.all? {|child| child.well_defined?(context)}
          value(ast_function, context).to_node.evaluate(context)
        else
          ast_function
        end
      end

      def simplify(ast_function, context = nil)
        context ||= Context.new

        if ast_function.children.all? {|child| child.is_a?(Keisan::AST::ConstantLiteral)}
          value(ast_function, context).to_node.simplify(context)
        else
          ast_function
        end
      end
    end
  end
end

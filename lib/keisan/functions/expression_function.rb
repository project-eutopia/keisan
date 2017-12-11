module Keisan
  module Functions
    class ExpressionFunction < Keisan::Function
      attr_reader :arguments, :expression

      def initialize(name, arguments, expression, transient_definitions)
        super(name)
        @expression = expression.deep_dup
        @arguments = arguments
        @transient_definitions = transient_definitions
      end

      def call(context, *args)
        unless @arguments.count == args.count
          raise Keisan::Exceptions::InvalidFunctionError.new("Invalid number of arguments for #{name} function")
        end

        local = local_context_for(context)
        arguments.each.with_index do |arg_name, i|
          local.register_variable!(arg_name, args[i])
        end

        expression.value(local)
      end

      def value(ast_function, context = nil)
        local = local_context_for(context)
        argument_values = ast_function.children.map {|child| child.value(local)}
        call(local, *argument_values)
      end

      def evaluate(ast_function, context = nil)
        local = local_context_for(context)

        argument_values = ast_function.children.map {|child| child.evaluate(local)}

        arguments.each.with_index do |arg_name, i|
          local.register_variable!(arg_name, argument_values[i].evaluate(local))
        end

        expression.evaluate(local)
      end

      def simplify(ast_function, context = nil)
        context = local_context_for(context)

        ast_function.instance_variable_set(
          :@children,
          ast_function.children.map {|child| child.evaluate(context)}
        )

        if ast_function.children.all? {|child| child.is_a?(Keisan::AST::ConstantLiteral)}
          value(ast_function, context).to_node.simplify(context)
        else
          ast_function
        end
      end

      private

      def local_context_for(context = nil)
        context ||= Keisan::Context.new
        case context
        when Keisan::FunctionDefinitionContext
          context.spawn_child(definitions: @transient_definitions, transient: true)
        when Keisan::Context
          Keisan::FunctionDefinitionContext.new(
            parent: context.spawn_child(definitions: @transient_definitions, transient: true),
            arguments: arguments
          )
        end
      end
    end
  end
end

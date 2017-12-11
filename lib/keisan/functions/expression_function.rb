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

      # Multi-argument functions work as follows:
      # Given f(x, y), in general we will take the derivative with respect to t,
      # and x = x(t), y = y(t).  For instance d/dt f(2*t, t+1).
      # In this case, chain rule gives derivative:
      # dx(t)/dt * f_x(x(t), y(t)) + dy(t)/dt * f_y(x(t), y(t)),
      # where f_x and f_y are the x and y partial derivatives respectively.
      def differentiate(ast_function, variable, context = nil)
        local = local_context_for(context)

        # expression.differentiate(variable, context)

        argument_values = ast_function.children.map {|child| child.evaluate(local)}

        argument_derivatives = ast_function.children.map do |child|
          child.differentiate(variable, context)
        end

        function_partial_derivatives = arguments.map {|argument| Keisan::AST::Variable.new(argument)}.map.with_index do |variable, i|
          partial_derivative = expression.differentiate(variable, context)
          partial_derivative.replace(variable, argument_values[i])
        end

        Keisan::AST::Plus.new(
          argument_derivatives.map.with_index {|argument_derivative, i|
            partial_derivative = function_partial_derivatives[i]
            Keisan::AST::Times.new([argument_derivative, partial_derivative])
          }
        )
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

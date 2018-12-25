module Keisan
  module Functions
    class ExpressionFunction < Function
      attr_reader :arguments, :expression

      def initialize(name, arguments, expression, transient_definitions)
        super(name, arguments.count)
        if expression.is_a?(::String)
          @expression = AST::parse(expression)
        else
          @expression = expression.deep_dup
        end
        @arguments = arguments
        @transient_definitions = transient_definitions
      end

      def call(context, *args)
        validate_arguments!(args.count)

        local = local_context_for(context)
        arguments.each.with_index do |arg_name, i|
          local.register_variable!(arg_name, args[i])
        end

        expression.value(local)
      end

      def value(ast_function, context = nil)
        validate_arguments!(ast_function.children.count)

        context ||= Context.new
        argument_values = ast_function.children.map {|child| child.value(context)}
        call(context, *argument_values)
      end

      def evaluate(ast_function, context = nil)
        validate_arguments!(ast_function.children.count)

        context ||= Context.new
        local = local_context_for(context)

        argument_values = ast_function.children.map {|child| child.evaluate(context)}

        arguments.each.with_index do |arg_name, i|
          local.register_variable!(arg_name, argument_values[i].evaluate(context))
        end

        expression.evaluated(local)
      end

      def simplify(ast_function, context = nil)
        validate_arguments!(ast_function.children.count)

        ast_function.instance_variable_set(
          :@children,
          ast_function.children.map {|child| child.evaluate(context)}
        )

        if ast_function.children.all? {|child| child.is_a?(AST::ConstantLiteral)}
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
        validate_arguments!(ast_function.children.count)

        local = local_context_for(context)

        argument_values = ast_function.children.map {|child| child.evaluated(local)}

        argument_derivatives = ast_function.children.map do |child|
          child.differentiated(variable, context)
        end

        partial_derivatives = calculate_partial_derivatives(context)

        AST::Plus.new(
          argument_derivatives.map.with_index {|argument_derivative, i|
            partial_derivative = partial_derivatives[i]
            argument_variables.each.with_index {|argument_variable, j|
              partial_derivative = partial_derivative.replaced(argument_variable, argument_values[j])
            }
            AST::Times.new([argument_derivative, partial_derivative])
          }
        )
      end

      private

      def argument_variables
        @argument_variables ||= arguments.map {|argument| AST::Variable.new(argument)}
      end

      def calculate_partial_derivatives(context)
        argument_variables.map.with_index do |variable, i|
          partial_derivative = expression.differentiated(variable, context)
        end
      end

      def local_context_for(context = nil)
        context ||= Context.new
        context.spawn_child(definitions: @transient_definitions, shadowed: @arguments, transient: true)
      end
    end
  end
end

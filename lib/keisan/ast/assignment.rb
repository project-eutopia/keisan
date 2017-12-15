module Keisan
  module AST
    class Assignment < Operator
      def self.symbol
        :"="
      end

      def evaluate(context = nil)
        context ||= Keisan::Context.new

        lhs = children.first
        rhs = children.last

        if is_variable_definition?
          evaluate_variable(context, lhs, rhs)
        elsif is_function_definition?
          evaluate_function(context, lhs, rhs)
        else
          raise Keisan::Exceptions::InvalidExpression.new("Unhandled left hand side #{lhs} in assignment")
        end
      end

      def simplify(context = nil)
        evaluate(context)
      end

      def unbound_variables(context = nil)
        variables = super(context)
        if is_variable_definition?
          variables.delete(children.first.name)
        else
          variables
        end
      end

      def unbound_functions(context = nil)
        functions = super(context)
        if is_function_definition?
          functions.delete(children.first.name)
        else
          functions
        end
      end

      def is_variable_definition?
        children.first.is_a?(Keisan::AST::Variable)
      end

      def is_function_definition?
        children.first.is_a?(Keisan::AST::Function)
      end

      private

      def evaluate_variable(context, lhs, rhs)
        rhs = rhs.evaluate(context)

        unless rhs.well_defined?
          raise Keisan::Exceptions::InvalidExpression.new("Right hand side of assignment to variable must be well defined")
        end

        rhs_value = rhs.value(context)
        context.register_variable!(lhs.name, rhs_value)
        # Return the variable assigned value
        rhs
      end

      def evaluate_function(context, lhs, rhs)
        unless lhs.children.all? {|arg| arg.is_a?(Keisan::AST::Variable)}
          raise Keisan::Exceptions::InvalidExpression.new("Left hand side function must have variables as arguments")
        end

        argument_names = lhs.children.map(&:name)
        function_definition_context = context.spawn_child(shadowed: argument_names, transient: true)

        unless rhs.unbound_variables(context) <= Set.new(argument_names)
          raise Keisan::Exceptions::InvalidExpression.new("Unbound variables found in function definition")
        end

        unless context.allow_recursive || rhs.unbound_functions(context).empty?
          raise Keisan::Exceptions::InvalidExpression.new("Unbound function definitions are not allowed by current context")
        end

        context.register_function!(
          lhs.name,
          Keisan::Functions::ExpressionFunction.new(
            lhs.name,
            argument_names,
            rhs,
            context.transient_definitions
          )
        )

        rhs
      end
    end
  end
end

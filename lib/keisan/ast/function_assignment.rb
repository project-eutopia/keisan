module Keisan
  module AST
    class FunctionAssignment
      attr_reader :context, :lhs, :rhs, :local

      def initialize(context, lhs, rhs, local)
        @context = context
        @lhs = lhs
        @rhs = rhs
        @local = local

        unless lhs.children.all? {|arg| arg.is_a?(Variable)}
          raise Exceptions::InvalidExpression.new("Left hand side function must have variables as arguments")
        end
      end

      def argument_names
        @argument_names ||= lhs.children.map(&:name)
      end

      def expression_function
        Functions::ExpressionFunction.new(
          lhs.name,
          argument_names,
          rhs.evaluate_assignments(context.spawn_child(shadowed: argument_names, transient: true)),
          context.transient_definitions
        )
      end

      def evaluate
        # Blocks might have local variable/function definitions, so skip check
        verify_rhs_of_function_assignment_is_valid! unless rhs.is_a?(Block)

        context.register_function!(lhs.name, expression_function, local: local)
        rhs
      end

      private

      def verify_rhs_of_function_assignment_is_valid!
        # Only variables that can appear are those that are arguments to the function
        unless rhs.unbound_variables(context) <= Set.new(argument_names)
          raise Exceptions::InvalidExpression.new("Unbound variables found in function definition")
        end
        # Cannot have undefined functions unless allowed by context
        unless context.allow_recursive || rhs.unbound_functions(context).empty?
          raise Exceptions::InvalidExpression.new("Unbound function definitions are not allowed by current context")
        end
      end
    end
  end
end

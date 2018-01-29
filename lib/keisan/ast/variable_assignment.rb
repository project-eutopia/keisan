module Keisan
  module AST
    class VariableAssignment
      attr_reader :assignment, :context, :lhs, :rhs

      def initialize(assignment, context, lhs, rhs)
        @assignment = assignment
        @context = context
        @lhs = lhs
        @rhs = rhs
      end

      def evaluate
        case assignment.compound_operator
        when :"||"
          evaluate_variable_or_assignment(context, lhs, rhs)
        when :"&&"
          evaluate_variable_and_assignment(context, lhs, rhs)
        else
          evaluate_variable_non_logical_assignment(context, lhs, rhs)
        end
      end

      private

      def evaluate_variable_or_assignment(context, lhs, rhs)
        if lhs.variable_truthy?(context)
          lhs
        else
          rhs = rhs.evaluate(context)
          context.register_variable!(lhs.name, rhs.value(context))
          rhs
        end
      end

      def evaluate_variable_and_assignment(context, lhs, rhs)
        if lhs.variable_truthy?(context)
          rhs = rhs.evaluate(context)
          context.register_variable!(lhs.name, rhs.value(context))
          rhs
        else
          context.register_variable!(lhs.name, nil) unless context.has_variable?(lhs.name)
          lhs
        end
      end

      def evaluate_variable_non_logical_assignment(context, lhs, rhs)
        rhs = rhs.evaluate(context)
        rhs_value = rhs.value(context)

        if assignment.compound_operator
          raise Exceptions::InvalidExpression.new("Compound assignment requires variable #{lhs.name} to already exist") unless context.has_variable?(lhs.name)
          rhs_value = context.variable(lhs.name).value.send(assignment.compound_operator, rhs_value)
        end

        context.register_variable!(lhs.name, rhs_value, local: assignment.local)
        # Return the variable assigned value
        rhs
      end
    end
  end
end

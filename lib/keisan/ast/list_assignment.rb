module Keisan
  module AST
    class ListAssignment
      attr_reader :assignment, :context, :lhs, :rhs

      def initialize(assignment, context, lhs, rhs)
        @assignment = assignment
        @context = context
        @lhs = lhs
        @rhs = rhs
      end

      def evaluate
        rhs = @rhs.evaluate(context)

        if !rhs.is_a?(List)
          raise Exceptions::InvalidExpression.new("To do multiple assigment, RHS must be a list")
        end
        if lhs.children.size != rhs.children.size
          raise Exceptions::InvalidExpression.new("To do multiple assigment, RHS list must have same length as LHS list")
        end

        i = 0
        while i < lhs.children.size
          lhs_variable = lhs.children[i]
          rhs_assignment = rhs.children[i]
          individual_assignment = Assignment.new(
            children = [lhs_variable, rhs_assignment],
            local: assignment.local,
            compound_operator: assignment.compound_operator
          )
          individual_assignment.evaluate(context)
          i += 1
        end
      end
    end
  end
end

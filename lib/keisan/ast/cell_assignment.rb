module Keisan
  module AST
    class CellAssignment
      attr_reader :assignment, :context, :lhs, :rhs

      def initialize(assignment, context, lhs, rhs)
        @assignment = assignment
        @context = context
        @lhs = lhs
        @rhs = rhs
      end

      def evaluate
        lhs = lhs_evaluate_and_check_modifiable

        unless lhs.is_a?(Cell)
          raise Exceptions::InvalidExpression.new("Unhandled left hand side #{lhs} in assignment")
        end

        case assignment.compound_operator
        when :"||"
          evaluate_cell_or_assignment(context, lhs, rhs)
        when :"&&"
          evaluate_cell_and_assignment(context, lhs, rhs)
        else
          evaluate_cell_non_logical_assignment(context, lhs, rhs)
        end
      end

      private

      def lhs_evaluate_and_check_modifiable
        res = lhs.evaluate(context)
        if res.frozen?
          raise Exceptions::UnmodifiableError.new("Cannot modify frozen variables")
        end
        res
      rescue RuntimeError => e
        raise Exceptions::UnmodifiableError.new("Cannot modify frozen variables") if e.message =~ /can't modify frozen/
        raise
      end

      def evaluate_cell_or_assignment(context, lhs, rhs)
        if lhs.false?
          rhs = rhs.evaluate(context)
          lhs.node = rhs.is_a?(Cell) ? rhs.node.deep_dup : rhs
          rhs
        else
          lhs
        end
      end

      def evaluate_cell_and_assignment(context, lhs, rhs)
        if lhs.true?
          rhs = rhs.evaluate(context)
          lhs.node = rhs.is_a?(Cell) ? rhs.node.deep_dup : rhs
          rhs
        else
          lhs
        end
      end

      def evaluate_cell_non_logical_assignment(context, lhs, rhs)
        rhs = rhs.evaluate(context)
        if assignment.compound_operator
          rhs = rhs.send(assignment.compound_operator, lhs.node).evaluate(context)
        end

        lhs.node = rhs.is_a?(Cell) ? rhs.node.deep_dup : rhs
        rhs
      end
    end
  end
end

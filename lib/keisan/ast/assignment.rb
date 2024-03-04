require_relative "variable_assignment"
require_relative "function_assignment"
require_relative "list_assignment"
require_relative "cell_assignment"

module Keisan
  module AST
    class Assignment < Operator
      attr_reader :local, :compound_operator

      def initialize(children = [], parsing_operators = [], local: false, compound_operator: nil)
        super(children, parsing_operators)
        @local = local
        @compound_operator = compound_operator
      end

      def self.symbol
        :"="
      end

      def symbol
        :"#{compound_operator}="
      end

      def evaluate(context = nil)
        context ||= Context.new

        lhs = children.first
        rhs = children.last

        if is_variable_definition?
          evaluate_variable_assignment(context, lhs, rhs)
        elsif is_function_definition?
          evaluate_function_assignment(context, lhs, rhs)
        elsif is_list_assignment?
          evaluate_list_assignment(context, lhs, rhs)
        else
          # Try cell assignment
          evaluate_cell_assignment(context, lhs, rhs)
        end
      end

      def simplify(context = nil)
        evaluate(context)
      end

      def evaluate_assignments(context = nil)
        evaluate(context)
      end

      def unbound_variables(context = nil)
        context ||= Context.new

        if is_variable_definition?
          variable_assignment_unbound_variables(context)
        else
          # TODO: Should update to handle function / list assignment.
          super(context)
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
        children.first.is_a?(Variable)
      end

      def variable_name
        children.first.name
      end

      def is_function_definition?
        children.first.is_a?(Function)
      end

      def is_list_assignment?
        children.first.is_a?(List)
      end

      def rhs_unbound_variables(context = nil)
        children.last.unbound_variables(context)
      end

      private

      def evaluate_variable_assignment(context, lhs, rhs)
        VariableAssignment.new(self, context, lhs, rhs).evaluate
      end

      def evaluate_function_assignment(context, lhs, rhs)
        raise Exceptions::InvalidExpression.new("Cannot do compound assignment on functions") if compound_operator
        FunctionAssignment.new(context, lhs, rhs, local).evaluate
      end

      def evaluate_list_assignment(context, lhs, rhs)
        ListAssignment.new(self, context, lhs, rhs).evaluate
      end

      def evaluate_cell_assignment(context, lhs, rhs)
        CellAssignment.new(self, context, lhs, rhs).evaluate
      end

      def variable_assignment_unbound_variables(context)
        rhs = rhs_unbound_variables(context)
        # If the right-side is fully defined, then this is a valid assignment.
        if rhs.empty?
          Set.new
        else
          rhs | Set.new([variable_name])
        end
      end
    end
  end
end

module Keisan
  module AST
    class MultiLine < Parent
      def value(context = nil)
        context ||= Context.new
        evaluate(context).value(context)
      end

      def evaluate_assignments(context = nil)
        self
      end

      def evaluate(context = nil)
        context ||= Context.new
        @children = children.map {|child| child.evaluate(context)}
        @children.last
      end

      def simplify(context = nil)
        evaluate(context)
      end

      def unbound_variables(context = nil)
        context ||= Context.new
        defined_variables = Set.new

        children.inject(Set.new) do |unbound_vars, child|
          if child.is_a?(Assignment) && child.is_variable_definition?
            line_unbound_vars = unbound_variables_for_line_variable_assignment(context, child, unbound_vars, defined_variables)
            if line_unbound_vars.empty?
              defined_variables.add(child.variable_name)
            end
            unbound_vars | line_unbound_vars
          else
            unbound_vars | (child.unbound_variables(context) - defined_variables)
          end
        end
      end

      def to_s
        children.map(&:to_s).join(";")
      end

      private

      def unbound_variables_for_line_variable_assignment(context, line, unbound_vars, defined_variables)
        child_unbound_variables = variable_assignment_unbound_variables(context, line, defined_variables)
        if child_unbound_variables.empty?
          defined_variables.add(line.variable_name)
          unbound_vars
        else
          unbound_vars | child_unbound_variables
        end
      end

      def variable_assignment_unbound_variables(context, assignment, defined_variables)
        rhs_child_unbound_variables = assignment.rhs_unbound_variables(context) - defined_variables

        # If there are no unbound variables, this is a properly bound assignment.
        if rhs_child_unbound_variables.empty?
          Set.new
        else
          Set.new([assignment.variable_name]) | rhs_child_unbound_variables
        end
      end
    end
  end
end

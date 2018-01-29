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
        children.first.is_a?(Variable)
      end

      def is_function_definition?
        children.first.is_a?(Function)
      end

      private

      def lhs_evaluate_and_check_modifiable(context, lhs)
        lhs.evaluate(context)
      rescue RuntimeError => e
        raise Exceptions::UnmodifiableError.new("Cannot modify frozen variables") if e.message =~ /can't modify frozen/
        raise
      end

      def evaluate_cell_assignment(context, lhs, rhs)
        lhs = lhs_evaluate_and_check_modifiable(context, lhs)

        unless lhs.is_a?(Cell)
          raise Exceptions::InvalidExpression.new("Unhandled left hand side #{lhs} in assignment")
        end

        case compound_operator
        when :"||"
          evaluate_cell_or_assignment(context, lhs, rhs)
        when :"&&"
          evaluate_cell_and_assignment(context, lhs, rhs)
        else
          evaluate_cell_non_logical_assignment(context, lhs, rhs)
        end
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
        if compound_operator
          rhs = rhs.send(compound_operator, lhs.node).evaluate(context)
        end

        lhs.node = rhs.is_a?(Cell) ? rhs.node.deep_dup : rhs
        rhs
      end

      def evaluate_variable_assignment(context, lhs, rhs)
        case compound_operator
        when :"||"
          evaluate_variable_or_assignment(context, lhs, rhs)
        when :"&&"
          evaluate_variable_and_assignment(context, lhs, rhs)
        else
          evaluate_variable_non_logical_assignment(context, lhs, rhs)
        end
      end

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

        if compound_operator
          raise Exceptions::InvalidExpression.new("Compound assignment requires variable #{lhs.name} to already exist") unless context.has_variable?(lhs.name)
          rhs_value = context.variable(lhs.name).value.send(compound_operator, rhs_value)
        end

        context.register_variable!(lhs.name, rhs_value, local: local)
        # Return the variable assigned value
        rhs
      end

      def evaluate_function_assignment(context, lhs, rhs)
        raise Exceptions::InvalidExpression.new("Cannot do compound assignment on functions") if compound_operator

        unless lhs.children.all? {|arg| arg.is_a?(Variable)}
          raise Exceptions::InvalidExpression.new("Left hand side function must have variables as arguments")
        end

        argument_names = lhs.children.map(&:name)

        verify_rhs_of_function_assignment_is_valid!(context, rhs, argument_names)

        context.register_function!(
          lhs.name,
          Functions::ExpressionFunction.new(
            lhs.name,
            argument_names,
            rhs.evaluate_assignments(context.spawn_child(shadowed: argument_names, transient: true)),
            context.transient_definitions
          ),
          local: local
        )

        rhs
      end

      def verify_rhs_of_function_assignment_is_valid!(context, rhs, argument_names)
        # Blocks might have local variable/function definitions, so skip check
        return if rhs.is_a?(Block)

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

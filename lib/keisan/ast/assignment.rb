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

        case lhs
        when Keisan::AST::Variable
          evaluate_variable(context, lhs, rhs)
        when Keisan::AST::Function
          evaluate_function(context, lhs, rhs)
        else
          raise Keisan::Exceptions::InvalidExpression.new("Unhandled left hand side #{lhs} in assignment")
        end
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
        function_definition_context = Keisan::FunctionDefinitionContext.new(
          parent: context,
          arguments: argument_names
        )
        rhs = rhs.evaluate(function_definition_context)

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

        # Return the function itself
        lhs
      end
    end
  end
end

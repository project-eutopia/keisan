module Keisan
  module AST
    class Assignment < Operator
      def self.symbol
        :"="
      end

      def evaluate(context = nil)
        context ||= Keisan::Context.new

        lhs = children.first
        rhs = children.last.evaluate(context)

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
        unless rhs.well_defined?
          raise Keisan::Exceptions::InvalidExpression.new("Right hand side of assignment to variable must be well defined")
        end

        rhs_value = rhs.value(context)
        context.register_variable!(lhs.name, rhs_value)
        rhs
      end

      def evaluate_function(context, lhs, rhs)
        unless lhs.children.all? {|arg| arg.is_a?(Keisan::AST::Variable)}
          raise Keisan::Exceptions::InvalidExpression.new("Left hand side function must have variables as arguments")
        end

        argument_names = lhs.children.map(&:name)

        unless rhs.unbound_variables(context) <= Set.new(argument_names)
          raise Keisan::Exceptions::InvalidExpression.new("Unbound variables found in function definition")
        end

        unless context.allow_recursive || rhs.unbound_functions(context).empty?
          raise Keisan::Exceptions::InvalidExpression.new("Unbound function definitions are not allowed by current context")
        end

        function = lambda do |*received_args|
          unless argument_names.count == received_args.count
            raise Keisan::Exceptions::InvalidFunctionError.new("Invalid number of arguments for #{name} function")
          end

          local = context.spawn_child
          argument_names.each.with_index do |arg, i|
            local.register_variable!(arg, received_args[i])
          end

          rhs.value(local)
        end

        context.register_function!(
          lhs.name,
          Keisan::Function.new(lhs.name, function)
        )

        rhs
      end
    end
  end
end

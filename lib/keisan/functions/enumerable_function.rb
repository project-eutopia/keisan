module Keisan
  module Functions
    class EnumerableFunction < Function
      # Filters lists/hashes:
      # (list, variable, boolean_expression)
      # (hash, key, value, boolean_expression)
      def initialize(name)
        super(name, -3)
      end

      def value(ast_function, context = nil)
        evaluate(ast_function, context)
      end

      def unbound_variables(children, context)
        super - Set.new(shadowing_variable_names(children).map(&:name))
      end

      def evaluate(ast_function, context = nil)
        validate_arguments!(ast_function.children.count)
        context ||= Context.new

        operand, arguments, expression = operand_arguments_expression_for(ast_function, context)

        case operand
        when AST::List
          evaluate_list(operand, arguments, expression, context).evaluate(context)
        when AST::Hash
          evaluate_hash(operand, arguments, expression, context).evaluate(context)
        else
          raise Exceptions::InvalidFunctionError.new("Unhandled first argument to #{name}: #{operand}")
        end
      end

      def simplify(ast_function, context = nil)
        evaluate(ast_function, context)
      end

      protected

      def shadowing_variable_names(children)
        raise Exceptions::NotImplementedError.new
      end

      def verify_arguments!(arguments)
        unless arguments.all? {|argument| argument.is_a?(AST::Variable)}
          raise Exceptions::InvalidFunctionError.new("Middle arguments to #{name} must be variables")
        end
      end

      private

      def operand_arguments_expression_for(ast_function, context)
        operand = ast_function.children[0].simplify(context)
        arguments = ast_function.children[1...-1]
        expression = ast_function.children[-1]

        verify_arguments!(arguments)

        [operand, arguments, expression]
      end
    end
  end
end

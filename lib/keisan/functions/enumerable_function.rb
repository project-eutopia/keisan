module Keisan
  module Functions
    class EnumerableFunction < Function
      # Filters lists/hashes:
      # (list, variable, boolean_expression)
      # (hash, key, value, boolean_expression)
      def initialize(name)
        super(name, ::Range.new(3, 4))
      end

      def value(ast_function, context = nil)
        evaluate(ast_function, context)
      end

      def evaluate(ast_function, context = nil)
        validate_arguments!(ast_function.children.count)
        context ||= Context.new

        operand, arguments, expression = operand_arguments_expression_for(ast_function, context)
        operand = operand.simplify(context)

        case operand
        when AST::List
          evaluate_list(operand, arguments, expression, context)
        when AST::Hash
          evaluate_hash(operand, arguments, expression, context)
        else
          raise Exceptions::InvalidFunctionError.new("Unhandled first argument to #{name}: #{operand}")
        end
      end

      def simplify(ast_function, context = nil)
        evaluate(ast_function, context)
      end

      private

      def operand_arguments_expression_for(ast_function, context)
        operand = ast_function.children[0].simplify(context)
        arguments = ast_function.children[1...-1]
        expression = ast_function.children[-1]

        unless arguments.all? {|argument| argument.is_a?(AST::Variable)}
          raise Exceptions::InvalidFunctionError.new("Middle arguments to map must be variables")
        end

        [operand, arguments, expression]
      end
    end
  end
end

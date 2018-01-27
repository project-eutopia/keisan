module Keisan
  module Functions
    class Map < Function
      # Maps
      # (list, variable, expression)
      # (hash, key, value, expression)
      def initialize
        super("map", ::Range.new(3,4))
      end

      def value(ast_function, context = nil)
        evaluate(ast_function, context)
      end

      def evaluate(ast_function, context = nil)
        validate_arguments!(ast_function.children.count)
        context ||= Context.new

        operand, arguments, expression = operand_arguments_expression_for(ast_function, context)

        case arguments.count
        when 1
          evaluate_list(operand, arguments[0], expression, context)
        when 2
          evaluate_hash(operand, arguments[0], arguments[1], expression, context)
        end
      end

      def simplify(ast_function, context = nil)
        evaluate(ast_function, context)
      end

      private

      def evaluate_list(list, variable, expression, context)
        unless list.is_a?(AST::List)
          raise Exceptions::InvalidFunctionError.new("Map with 3 arguments must work on list")
        end

        local = context.spawn_child(transient: false, shadowed: [variable.name])

        AST::List.new(
          list.children.map do |element|
            local.register_variable!(variable, element)
            expression.simplified(local)
          end
        )
      end

      def evaluate_hash(hash, key, value, expression, context)
        unless hash.is_a?(AST::Hash)
          raise Exceptions::InvalidFunctionError.new("Map with 4 arguments must work on hash")
        end

        local = context.spawn_child(transient: false, shadowed: [key.name, value.name])

        AST::List.new(
          hash.map do |cur_key, cur_value|
            local.register_variable!(key, cur_key)
            local.register_variable!(value, cur_value)
            expression.simplified(local)
          end
        )
      end

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

module Keisan
  module Functions
    class Filter < Function
      # Filters (list, variable, expression)
      # e.g. filter([1,2,3,4], x, x % 2 == 0)
      # should give [2,4]
      def initialize
        super("filter", 3)
      end

      def value(ast_function, context = nil)
        evaluate(ast_function, context)
      end

      def evaluate(ast_function, context = nil)
        context ||= Context.new
        simplify(ast_function, context).evaluate(context)
      end

      def simplify(ast_function, context = nil)
        validate_arguments!(ast_function.children.count)

        context ||= Context.new
        list, variable, expression = list_variable_expression_for(ast_function, context)

        local = context.spawn_child(transient: false, shadowed: [variable.name])

        AST::List.new(
          list.children.select do |element|
            local.register_variable!(variable, element)
            result = expression.evaluate(local)

            case result
            when AST::Boolean
              result.value
            else
              raise Exceptions::InvalidFunctionError.new("Filter requires expression to be a logical expression")
            end
          end
        )
      end

      private

      def list_variable_expression_for(ast_function, context)
        list = ast_function.children[0].simplify(context)
        variable = ast_function.children[1]
        expression = ast_function.children[2]

        unless list.is_a?(AST::List)
          raise Exceptions::InvalidFunctionError.new("First argument to filter must be a list")
        end

        unless variable.is_a?(AST::Variable)
          raise Exceptions::InvalidFunctionError.new("Second argument to filter must be a variable")
        end

        [list, variable, expression]
      end
    end
  end
end

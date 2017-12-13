module Keisan
  module Functions
    class Filter < Keisan::Function
      # Filters (list, variable, expression)
      # e.g. filter([1,2,3,4], x, x % 2 == 0)
      # should give [2,4]
      def initialize
        @name = "filter"
      end

      def value(ast_function, context = nil)
        evaluate(ast_function, context = nil)
      end

      def evaluate(ast_function, context = nil)
        context ||= Context.new
        simplify(ast_function).evaluate(context)
      end

      def simplify(ast_function, context = nil)
        list, variable, expression = list_variable_expression_for(ast_function)

        context ||= Keisan::Context.new
        local = context.spawn_child(transient: false)

        Keisan::AST::List.new(
          list.children.select do |element|
            local.register_variable!(variable, element)
            result = expression.evaluate(local)

            case result
            when Keisan::AST::Boolean
              result.value
            else
              raise Keisan::Exceptions::InvalidFunctionError.new("Filter requires expression to be a logical expression")
            end
          end
        )
      end

      private

      def list_variable_expression_for(ast_function)
        unless ast_function.children.size == 3
          raise Keisan::Exceptions::InvalidFunctionError.new("Require 3 arguments to map")
        end

        list = ast_function.children[0]
        variable = ast_function.children[1]
        expression = ast_function.children[2]

        unless list.is_a?(Keisan::AST::List)
          raise Keisan::Exceptions::InvalidFunctionError.new("First argument to map must be a list")
        end

        unless variable.is_a?(Keisan::AST::Variable)
          raise Keisan::Exceptions::InvalidFunctionError.new("First argument to map must be a list")
        end

        [list, variable, expression]
      end
    end
  end
end

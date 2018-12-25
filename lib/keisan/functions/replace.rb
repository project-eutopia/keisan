module Keisan
  module Functions
    class Replace < Function
      def initialize
        @name = "replace"
      end

      def value(ast_function, context = nil)
        context ||= Context.new
        evaluate(ast_function, context).value(context)
      end

      def simplify(ast_function, context = nil)
        context ||= Context.new
        expression, variable, replacement = expression_variable_replacement(ast_function)

        expression = expression.simplify(context)
        replacement = replacement.simplify(context)

        expression.replace(variable, replacement).simplify(context)
      end

      def evaluate(ast_function, context = nil)
        context ||= Context.new
        simplify(ast_function, context).evaluate(context)
      end

      private

      def expression_variable_replacement(ast_function)
        unless ast_function.is_a?(AST::Function) && ast_function.name == name
          raise Exceptions::InvalidFunctionError.new("Must receive replace function")
        end

        unless ast_function.children.size == 3
          raise Exceptions::InvalidFunctionError.new("Require 3 arguments to replace")
        end

        expression, variable, replacement = *ast_function.children.map(&:deep_dup)

        unless variable.is_a?(AST::Variable)
          raise Exceptions::InvalidFunctionError.new("Replace must replace a variable")
        end

        [expression, variable, replacement]
      end
    end
  end
end

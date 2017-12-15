module Keisan
  module Functions
    class Reduce < Function
      # Reduces (list, initial, accumulator, variable, expression)
      # e.g. reduce([1,2,3,4], 0, total, x, total+x)
      # should give 10
      def initialize
        @name = "reduce"
      end

      def value(ast_function, context = nil)
        evaluate(ast_function, context = nil)
      end

      def evaluate(ast_function, context = nil)
        context ||= Context.new
        simplify(ast_function, context).evaluate(context)
      end

      def simplify(ast_function, context = nil)
        context ||= Context.new
        list, initial, accumulator, variable, expression = list_initial_accumulator_variable_expression_for(ast_function, context)

        local = context.spawn_child(transient: false, shadowed: [accumulator.name, variable.name])
        local.register_variable!(accumulator, initial.simplify(context))

        list.children.each do |element|
          local.register_variable!(variable, element)
          result = expression.simplified(local)
          local.register_variable!(accumulator, result)
        end

        local.variable(accumulator.name)
      end

      private

      def list_initial_accumulator_variable_expression_for(ast_function, context)
        unless ast_function.children.size == 5
          raise Exceptions::InvalidFunctionError.new("Require 5 arguments to reduce")
        end

        list = ast_function.children[0].simplify(context)
        initial = ast_function.children[1]
        accumulator = ast_function.children[2]
        variable = ast_function.children[3]
        expression = ast_function.children[4]

        unless list.is_a?(AST::List)
          raise Exceptions::InvalidFunctionError.new("First argument to reduce must be a list")
        end

        unless accumulator.is_a?(AST::Variable)
          raise Exceptions::InvalidFunctionError.new("Third argument to reduce is accumulator and must be a variable")
        end

        unless variable.is_a?(AST::Variable)
          raise Exceptions::InvalidFunctionError.new("Fourth argument to reduce is variable and must be a variable")
        end

        [list, initial, accumulator, variable, expression]
      end
    end
  end
end

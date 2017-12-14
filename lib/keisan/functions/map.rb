module Keisan
  module Functions
    class Map < Keisan::Function
      # Maps (list, variable, expression)
      # e.g. map([1,2,3], x, 2*x)
      # should give [2,4,6]
      def initialize
        @name = "map"
      end

      def value(ast_function, context = nil)
        evaluate(ast_function, context = nil)
      end

      def evaluate(ast_function, context = nil)
        context ||= Context.new
        simplify(ast_function, context).evaluate(context)
      end

      def simplify(ast_function, context = nil)
        list, variable, expression = list_variable_expression_for(ast_function)

        context ||= Keisan::Context.new
        local = context.spawn_child(transient: false, shadowed: [variable.name])

        Keisan::AST::List.new(
          list.children.map do |element|
            local.register_variable!(variable, element)
            expression.simplified(local)
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
          raise Keisan::Exceptions::InvalidFunctionError.new("Second argument to map must be a variable")
        end

        [list, variable, expression]
      end
    end
  end
end

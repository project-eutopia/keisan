module Keisan
  module Functions
    class Diff < Keisan::Function
      def initialize
        @name = "diff"
      end

      def value(ast_function, context = nil)
        context ||= Keisan::Context.new
        evaluation = evaluate(ast_function, context)

        if is_ast_derivative?(evaluation)
          raise Keisan::Exceptions::NonDifferentiableError.new
        else
          evaluation.value(context)
        end
      end

      def evaluate(ast_function, context = nil)
        context ||= Context.new
        function, vars = function_and_vars(ast_function)

        vars.inject(function.evaluate(context)) do |result, variable|
          result = differentiate(result, variable, context)
          if !is_ast_derivative?(result)
            result = result.evaluate(context)
          end
          result
        end
      end

      def simplify(ast_function, context = nil)
        context ||= Context.new
        function, vars = function_and_vars(ast_function)

        vars.inject(function.simplify(context)) do |result, variable|
          result = differentiate(result, variable, context)
          if !is_ast_derivative?(result)
            result = result.simplify(context)
          end
          result
        end
      end

      private

      def is_ast_derivative?(node)
        node.is_a?(Keisan::AST::Function) && node.name == name
      end

      def differentiate(node, variable, context)
        if node.unbound_variables(context).include?(variable.name)
          node.differentiate(variable, context)
        else
          return AST::Number.new(0)
        end
      rescue Keisan::Exceptions::NonDifferentiableError => e
        return AST::Function.new(
          [node, variable],
          "diff"
        )
      end

      def function_and_vars(ast_function)
        unless ast_function.is_a?(Keisan::AST::Function) && ast_function.name == name
          raise Keisan::Exceptions::InvalidFunctionError.new("Must receive diff function")
        end

        vars = ast_function.children[1..-1]

        unless vars.all? {|var| var.is_a?(AST::Variable)}
          raise Keisan::Exceptions::InvalidFunctionError.new("Diff must differentiate with respect to variables")
        end

        [
          ast_function.children.first,
          vars
        ]
      end
    end
  end
end

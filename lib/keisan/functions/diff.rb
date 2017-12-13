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
        context ||= Keisan::Context.new
        function, variables = function_and_variables(ast_function)
        local = context_from(variables, context)

        result = variables.inject(function.evaluate(local)) do |result, variable|
          result = differentiate(result, variable, local)
          if !is_ast_derivative?(result)
            result = result.evaluate(local)
          end
          result
        end

        case result
        when Keisan::AST::Function
          result.name == "diff" ? result : result.simplify(context)
        else
          result.simplify(context)
        end
      end

      def simplify(ast_function, context = nil)
        raise Keisan::Exceptions::InternalError.new("received non-diff function") unless ast_function.name == "diff"
        function, variables = function_and_variables(ast_function)
        context ||= Keisan::Context.new
        local = context_from(variables, context)

        result = variables.inject(function.simplify(local)) do |result, variable|
          result = differentiate(result, variable, local)
          if !is_ast_derivative?(result)
            result = result.simplify(local)
          end
          result
        end

        case result
        when Keisan::AST::Function
          result.name == "diff" ? result : result.simplify(context)
        else
          result.simplify(context)
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

      def function_and_variables(ast_function)
        unless ast_function.is_a?(Keisan::AST::Function) && ast_function.name == name
          raise Keisan::Exceptions::InvalidFunctionError.new("Must receive diff function")
        end

        variables = ast_function.children[1..-1]

        unless variables.all? {|var| var.is_a?(AST::Variable)}
          raise Keisan::Exceptions::InvalidFunctionError.new("Diff must differentiate with respect to variables")
        end

        [
          ast_function.children.first,
          variables
        ]
      end

      def context_from(variables, context = nil)
        context ||= Keisan::Context.new(shadowed: variables.map(&:name))
        context.spawn_child(shadowed: variables.map(&:name))
      end
    end
  end
end

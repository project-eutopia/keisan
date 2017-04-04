module Keisan
  module Functions
    class Diff < Keisan::Function
      def initialize
        @name = "diff"
      end

      def value(ast_function, context = nil)
        context ||= Keisan::Context.new
        # TODO
        ast_function
      end

      def evaluate(ast_function, context = nil)
        context ||= Keisan::Context.new
        # TODO
        ast_function
      end

      def simplify(ast_function, context = nil)
        context ||= Context.new

        function, vars = function_and_vars(ast_function)

        result = function.simplify(context)

        while vars.size > 0
          begin
            var = vars.first
            if result.unbound_variables(context).include?(var.name)
              result = result.differentiate(var, context).simplify(context)
            else
              return AST::Number.new(0)
            end
          rescue Keisan::Exceptions::NonDifferentiableError => e
            return AST::Function.new(
              [result] + vars,
              "diff"
            )
          end

          vars.shift
        end

        result
      end

      private

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

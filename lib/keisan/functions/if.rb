module Keisan
  module Functions
    class If < Keisan::Function
      def initialize
        @name = "if"
      end

      def value(ast_function, context = nil)
        evaluate(ast_function, context)
      end

      def evaluate(ast_function, context = nil)
        context ||= Keisan::Context.new

        bool = ast_function.children[0].evaluate(context)

        if bool.is_a?(Keisan::AST::Boolean)
          node = bool.value ? ast_function.children[1] : ast_function.children[2]
          node.to_node.evaluate(context)
        else
          ast_function
        end
      end

      def simplify(ast_function, context = nil)
        context ||= Context.new
        bool = ast_function.children[0].simplify(context)

        if bool.is_a?(Keisan::AST::Boolean)
          if bool.value
            ast_function.children[1].to_node.simplify(context)
          else
            ast_function.children[2].to_node.simplify(context)
          end
        else
          ast_function
        end
      end

      def differentiate(ast_function, variable, context = nil)
        context ||= Context.new
        Keisan::AST::Function.new(
          [
            ast_function.children[0],
            ast_function.children[1].differentiate(variable, context),
            ast_function.children[2].differentiate(variable, context)
          ],
          @name
        )
      end
    end
  end
end

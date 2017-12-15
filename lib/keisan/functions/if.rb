module Keisan
  module Functions
    class If < Function
      def initialize
        @name = "if"
      end

      def value(ast_function, context = nil)
        context ||= Context.new

        unless (2..3).cover? ast_function.children.size
          raise Exceptions::InvalidFunctionError.new("Require 2 or 3 arguments to if")
        end

        bool = ast_function.children[0].value(context)

        if bool
          ast_function.children[1].value(context)
        else
          ast_function.children.size == 3 ? ast_function.children[2].value(context) : nil
        end
      end

      def evaluate(ast_function, context = nil)
        context ||= Context.new

        bool = ast_function.children[0].evaluate(context)

        if bool.is_a?(AST::Boolean)
          node = bool.value ? ast_function.children[1] : ast_function.children[2]
          node.to_node.evaluate(context)
        else
          ast_function
        end
      end

      def simplify(ast_function, context = nil)
        context ||= Context.new
        bool = ast_function.children[0].simplify(context)

        if bool.is_a?(AST::Boolean)
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
        AST::Function.new(
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

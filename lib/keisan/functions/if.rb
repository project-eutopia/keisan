module Keisan
  module Functions
    class If < Keisan::Function
      def initialize
        super("if", Range.new(2,3))
      end

      def value(ast_function, context = nil)
        validate_arguments!(ast_function.children.count)
        evaluate(ast_function, context)
      end

      def evaluate(ast_function, context = nil)
        validate_arguments!(ast_function.children.count)
        context ||= Keisan::Context.new

        bool = ast_function.children[0].evaluate(context)

        if bool.is_a?(Keisan::AST::Boolean)
          if bool.value
            ast_function.children[1]
          elsif ast_function.children.size >= 2
            ast_function.children[2]
          else
            Keisan::AST::Null.new
          end.to_node.evaluate(context)
        else
          ast_function
        end
      end

      def simplify(ast_function, context = nil)
        validate_arguments!(ast_function.children.count)
        context ||= Context.new
        bool = ast_function.children[0].simplify(context)

        if bool.is_a?(Keisan::AST::Boolean)
          if bool.value
            ast_function.children[1].to_node.simplify(context)
          elsif ast_function.children.size >= 2
            ast_function.children[2].to_node.simplify(context)
          else
            Keisan::AST::Null.new
          end
        else
          ast_function
        end
      end

      def differentiate(ast_function, variable, context = nil)
        validate_arguments!(ast_function.children.count)
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

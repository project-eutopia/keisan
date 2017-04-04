module Keisan
  module Functions
    class If < Keisan::Function
      def initialize
        @name = "if"
      end

      def value(ast_function, context = nil)
        context ||= Keisan::Context.new

        unless (2..3).cover? ast_function.children.size
          raise Keisan::Exceptions::InvalidFunctionError.new("Require 2 or 3 arguments to if")
        end

        bool = ast_function.children[0].value(context)

        if bool
          ast_function.children[1].value(context)
        else
          ast_function.children.size == 3 ? ast_function.children[2].value(context) : nil
        end
      end

      def evaluate(ast_function, context = nil)
        context ||= Keisan::Context.new

        bool = ast_function.children[0].evaluate(context)

        if bool.is_a?(Keisan::AST::Boolean)
          if bool.value
            ast_function.children[1].evaluate(context)
          else
            ast_function.children[2].to_node.evaluate(context)
          end
        else
          ast_function
        end

        if ast_function.children.all? {|child| child.well_defined?(context)}
          value(ast_function, context).to_node.evaluate(context)
        else
          ast_function
        end
      end

      def simplify(ast_function, context = nil)
        context ||= Context.new
        bool = ast_function.children[0].simplify(context)

        if bool.is_a?(Keisan::AST::Boolean)
          if bool.value
            ast_function.children[1].simplify(context)
          else
            ast_function.children[2].to_node.simplify(context)
          end
        else
          ast_function
        end
      end
    end
  end
end

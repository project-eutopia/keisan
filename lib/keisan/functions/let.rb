module Keisan
  module Functions
    class Let < Function
      def initialize
        super("let", ::Range.new(1,2))
      end

      def value(ast_function, context = nil)
        evaluate(ast_function, context)
      end

      def evaluate(ast_function, context = nil)
        validate_arguments!(ast_function.children.count)
        assignment(ast_function).evaluate(context)
      end

      def simplify(ast_function, context = nil)
        evaluate(ast_function, context)
      end

      private

      def assignment(ast_function)
        if ast_function.children.count == 1
          unless ast_function.children.first.is_a?(AST::Assignment)
            raise Exceptions::InvalidFunctionError.new("`let` must accept assignment if given one argument")
          end

          AST::Assignment.new(ast_function.children.first.children, local: true)
        else
          AST::Assignment.new(ast_function.children, local: true)
        end
      end
    end
  end
end

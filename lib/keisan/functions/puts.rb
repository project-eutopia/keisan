module Keisan
  module Functions
    class Puts < Function
      def initialize
        super("puts", 1)
      end

      def value(ast_function, context = nil)
        evaluate(ast_function, context)
      end

      def evaluate(ast_function, context = nil)
        validate_arguments!(ast_function.children.count)
        puts ast_function.children.first.evaluate(context).to_s
      end

      def simplify(ast_function, context = nil)
        evaluate(ast_function, context)
      end
    end
  end
end

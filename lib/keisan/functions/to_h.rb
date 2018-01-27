module Keisan
  module Functions
    class ToH < Function
      def initialize
        super("to_h", 1)
      end

      def value(ast_function, context = nil)
        validate_arguments!(ast_function.children.count)
        evaluate(ast_function, context).value(context)
      end

      def evaluate(ast_function, context = nil)
        validate_arguments!(ast_function.children.count)
        context ||= Context.new

        child = ast_function.children[0].simplify(context)

        case child
        when AST::List
          AST::Hash.new(child.children)
        when AST::Hash
          child
        else
          raise Exceptions::InvalidFunctionError.new("Cannot call to_h on a #{child.class}")
        end
      end

      def simplify(ast_function, context = nil)
        evaluate(ast_function, context)
      end
    end
  end
end

module Keisan
  module Functions
    class While < Keisan::Function
      def initialize
        super("while", 2)
      end

      def value(ast_function, context = nil)
        validate_arguments!(ast_function.children.count)
        evaluate(ast_function, context)
      end

      def evaluate(ast_function, context = nil)
        validate_arguments!(ast_function.children.count)
        context ||= Keisan::Context.new
        simplify(ast_function, context)
      end

      def simplify(ast_function, context = nil)
        validate_arguments!(ast_function.children.count)
        context ||= Context.new

        current = Keisan::AST::Null.new

        loop do
          bool = ast_function.children[0].deep_dup.evaluate(context)
          case bool
          when Keisan::AST::Boolean
            break unless bool.value
            current = ast_function.children[1].deep_dup.evaluate(context)
          else
            raise Keisan::Exceptions::InvalidFunctionError.new("while condition must evaluate to a boolean")
          end
        end

        current
      end
    end
  end
end

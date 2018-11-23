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
        while_loop(ast_function.children[0], ast_function.children[1], context)
      end

      private

      def while_loop(logical_node, body_node, context)
        current = Keisan::AST::Null.new

        while logical_node_evaluates_to_true(logical_node, context)
          begin
            current = body_node.evaluated(context)
          rescue Exceptions::BreakError
            break
          rescue Exceptions::ContinueError
            next
          end
        end

        current
      end

      def logical_node_evaluates_to_true(logical_node, context)
        bool = logical_node.evaluated(context)
        unless bool.is_a?(AST::Boolean)
          raise Keisan::Exceptions::InvalidFunctionError.new("while condition must evaluate to a boolean")
        end
        bool.value(context)
      end
    end
  end
end

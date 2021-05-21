module Keisan
  module Functions
    class While < Keisan::Function
      class WhileLogicalNodeIsNotConstant < Keisan::Exceptions::StandardError; end
      class WhileLogicalNodeIsNonBoolConstant < Keisan::Exceptions::StandardError; end

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
        while_loop(ast_function, context, simplify: false)
      end

      def simplify(ast_function, context = nil)
        validate_arguments!(ast_function.children.count)
        context ||= Context.new
        while_loop(ast_function, context, simplify: true)
      end

      private

      def while_loop(ast_function, context, simplify: true)
        logical_node, body_node = ast_function.children[0], ast_function.children[1]
        current = Keisan::AST::Null.new

        begin
          while logical_node_evaluates_to_true(logical_node, context)
            begin
              current = body_node.evaluated(context)
            rescue Exceptions::BreakError
              break
            rescue Exceptions::ContinueError
              next
            end
          end

        # While loops should work on booleans, not other types of constants
        rescue WhileLogicalNodeIsNonBoolConstant
          raise Keisan::Exceptions::InvalidFunctionError.new("while condition must evaluate to a boolean")

        # If the logical expression is not constant (e.g. boolean), then we
        # cannot simplify the while loop, and an evaluate should raise an error.
        rescue WhileLogicalNodeIsNotConstant
          if simplify
            return ast_function
          else
            raise Keisan::Exceptions::InvalidFunctionError.new("while condition must evaluate to a boolean")
          end
        end

        current
      end

      def logical_node_evaluates_to_true(logical_node, context)
        bool = logical_node.evaluated(context).to_node

        if bool.is_a?(AST::Boolean)
          bool.value(context)
        elsif bool.is_constant?
          raise WhileLogicalNodeIsNonBoolConstant.new
        else
          raise WhileLogicalNodeIsNotConstant.new
        end
      end
    end
  end
end

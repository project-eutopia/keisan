module Keisan
  module Functions
    class ProcFunction < Keisan::Function
      def initialize(name, function_proc)
        raise Keisan::Exceptions::InvalidFunctionError.new unless function_proc.is_a?(Proc)

        super(name)
        @function_proc = function_proc
      end

      def call(context, *args)
        @function_proc.call(*args)
      end

      def value(ast_function, context = nil)
        context ||= Keisan::Context.new
        argument_values = ast_function.children.map {|child| child.value(context)}
        call(context, *argument_values)
      end

      def evaluate(ast_function, context = nil)
        if ast_function.children.all? {|child| child.well_defined?(context)}
          value(ast_function, context).to_node.evaluate(context)
        else
          ast_function
        end
      end

      def simplify(ast_function, context = nil)
        context ||= Context.new

        if ast_function.children.all? {|child| child.is_a?(Keisan::AST::ConstantLiteral)}
          value(ast_function, context).to_node.simplify(context)
        else
          ast_function
        end
      end
    end
  end
end

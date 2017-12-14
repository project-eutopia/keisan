module Keisan
  module Functions
    class ProcFunction < Keisan::Function
      attr_reader :function_proc

      def initialize(name, function_proc)
        raise Keisan::Exceptions::InvalidFunctionError.new unless function_proc.is_a?(Proc)

        super(name, function_proc.arity)
        @function_proc = function_proc
      end

      def call(context, *args)
        validate_arguments!(args.count)
        function_proc.call(*args).to_node
      end

      def value(ast_function, context = nil)
        validate_arguments!(ast_function.children.count)
        context ||= Keisan::Context.new
        argument_values = ast_function.children.map {|child| child.value(context)}
        call(context, *argument_values).value(context)
      end

      def evaluate(ast_function, context = nil)
        validate_arguments!(ast_function.children.count)
        context ||= Keisan::Context.new

        ast_function.instance_variable_set(
          :@children,
          ast_function.children.map {|child| child.evaluate(context).to_node}
        )

        if ast_function.children.all? {|child| child.well_defined?(context)}
          value(ast_function, context).to_node.evaluate(context)
        else
          ast_function
        end
      end

      def simplify(ast_function, context = nil)
        validate_arguments!(ast_function.children.count)
        context ||= Context.new

        ast_function.instance_variable_set(
          :@children,
          ast_function.children.map {|child| child.evaluate(context)}
        )

        if ast_function.children.all? {|child| child.is_a?(Keisan::AST::ConstantLiteral)}
          value(ast_function, context).to_node.simplify(context)
        else
          ast_function
        end
      end
    end
  end
end

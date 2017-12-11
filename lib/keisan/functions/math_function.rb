module Keisan
  module Functions
    class MathFunction < ProcFunction
      def initialize(name)
        super(name, Proc.new {|arg| Math.send(name, arg)})
      end

      def simplify(ast_function, context = nil)
        simplified = super
        self.class.apply_simplifications(simplified)
      end

      def differentiate(ast_function, variable, context = nil)
        raise Keisan::Exceptions::InvalidFunctionError.new unless ast_function.children.count == 1
        context ||= Context.new

        argument_simplified = ast_function.children.first.simplify(context)
        argument_differentiated = argument_simplified.differentiate(variable, context)

        self.class.derivative(argument_simplified, argument_differentiated).simplify(context)
      end

      protected

      def self.derivative(argument_simplified, argument_differentiated)
        raise Keisan::Exceptions::NotImplementedError.new
      end

      def self.apply_simplifications(simplified)
        simplified
      end
    end
  end
end

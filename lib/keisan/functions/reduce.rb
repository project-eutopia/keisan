require "keisan/functions/enumerable_function"

module Keisan
  module Functions
    class Reduce < EnumerableFunction
      # Reduces (list, initial, accumulator, variable, expression)
      # e.g. reduce([1,2,3,4], 0, total, x, total+x)
      # should give 10
      def initialize
        super("reduce")
      end

      protected

      def verify_arguments!(arguments)
        unless arguments[1..-1].all? {|argument| argument.is_a?(AST::Variable)}
          raise Exceptions::InvalidFunctionError.new("Middle arguments to #{name} must be variables")
        end
      end

      private

      def evaluate_list(list, arguments, expression, context)
        unless arguments.count == 3
          raise Exceptions::InvalidFunctionError.new("Reduce on list must take 3 arguments")
        end

        initial, accumulator, variable = arguments[0...3]

        local = context.spawn_child(transient: false, shadowed: [accumulator.name, variable.name])
        local.register_variable!(accumulator, initial.simplify(context))

        list.children.each do |element|
          local.register_variable!(variable, element)
          result = expression.simplified(local)
          local.register_variable!(accumulator, result)
        end

        local.variable(accumulator.name)
      end
    end
  end
end

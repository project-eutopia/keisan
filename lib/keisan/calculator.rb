module Keisan
  class Calculator
    attr_reader :context

    def initialize(context = nil)
      @context = context || Context.new
    end

    def evaluate(expression, definitions = {})
      Evaluator.new(self).evaluate(expression, definitions)
    end

    def define_variable!(name, value)
      context.register_variable!(name, value)
    end

    def define_function!(name, function)
      context.register_function!(name, function)
    end
  end
end

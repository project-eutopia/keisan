module Keisan
  class Calculator
    attr_reader :context

    # Note, allow_recursive would be more appropriately named:
    # allow_unbound_functions_in_function_definitions, but it is too late for that.
    def initialize(context: nil, allow_recursive: false, allow_blocks: true, allow_multiline: true, allow_random: true)
      @context = context || Context.new(
        allow_recursive: allow_recursive,
        allow_blocks: allow_blocks,
        allow_multiline: allow_multiline,
        allow_random: allow_random
      )
    end

    def allow_recursive
      context.allow_recursive
    end

    def allow_recursive!
      context.allow_recursive!
    end

    def allow_blocks
      context.allow_blocks
    end

    def allow_multiline
      context.allow_multiline
    end

    def allow_random
      context.allow_random
    end

    def evaluate(expression, definitions = {})
      Evaluator.new(self).evaluate(expression, definitions)
    end

    def simplify(expression, definitions = {})
      Evaluator.new(self).simplify(expression, definitions)
    end

    def ast(expression)
      Evaluator.new(self).parse_ast(expression)
    end

    def define_variable!(name, value)
      context.register_variable!(name, value)
    end

    def define_function!(name, function)
      context.register_function!(name, function)
    end
  end
end

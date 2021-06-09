module Keisan
  class Calculator
    attr_reader :context

    # Note, allow_recursive would be more appropriately named:
    # allow_unbound_functions_in_function_definitions, but it is too late for that.
    def initialize(context: nil, allow_recursive: false, allow_blocks: true, allow_multiline: true, allow_random: true, cache: nil)
      @context = context || Context.new(
        allow_recursive: allow_recursive,
        allow_blocks: allow_blocks,
        allow_multiline: allow_multiline,
        allow_random: allow_random
      )
      @cache = case cache
               when nil, false
                 nil
               when true
                 AST::Cache.new
               when AST::Cache
                 cache
               else
                 raise Exceptions::StandardError.new("cache must be either nil, false, true, or an instance of Keisan::AST::Cache")
               end
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
      Evaluator.new(self, cache: @cache).evaluate(expression, definitions)
    end

    def evaluate_ast(ast, definitions = {})
      Evaluator.new(self, cache: @cache).evaluate_ast(ast, definitions: definitions)
    end

    def simplify(expression, definitions = {})
      Evaluator.new(self, cache: @cache).simplify(expression, definitions)
    end

    def simplify_ast(ast, definitions = {})
      Evaluator.new(self, cache: @cache).simplify_ast(ast, definitions: definitions)
    end

    def ast(expression)
      Evaluator.new(self, cache: @cache).parse_ast(expression)
    end

    def define_variable!(name, value)
      context.register_variable!(name, value)
    end

    def define_function!(name, function)
      context.register_function!(name, function)
    end
  end
end

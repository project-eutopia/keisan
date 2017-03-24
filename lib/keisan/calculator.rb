module Keisan
  class Calculator
    attr_reader :context

    def initialize(context = nil)
      @context = context || Context.new
    end

    def evaluate(expression, definitions = {})
      local_context = context.spawn_child
      definitions.each do |name, value|
        case value
        when Proc
          local_context.register_function!(name, value)
        else
          local_context.register_variable!(name, value)
        end
      end
      Keisan::AST::Builder.new(string: expression).ast.value(local_context)
    end

    def define_variable!(name, value)
      context.register_variable!(name, value)
    end

    def define_function!(name, function)
      context.register_function!(name, function)
    end
  end
end

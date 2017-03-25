module Keisan
  class Calculator
    attr_reader :context

    def initialize(context = nil)
      @context = context || Context.new
    end

    def evaluate(expression, definitions = {})
      context.spawn_child do |local|
        definitions.each do |name, value|
          case value
          when Proc
            local.register_function!(name, value)
          else
            local.register_variable!(name, value)
          end
        end

        Keisan::AST::Builder.new(string: expression).ast.value(local)
      end
    end

    def define_variable!(name, value)
      context.register_variable!(name, value)
    end

    def define_function!(name, function)
      context.register_function!(name, function)
    end
  end
end

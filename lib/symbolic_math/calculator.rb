module SymbolicMath
  class Calculator
    attr_reader :context

    def initialize(context = nil)
      @context = context || Context.new
    end

    def evaluate(expression, variables = {})
      local_context = context.spawn_child
      variables.each do |name, value|
        local_context.register_variable!(name, value)
      end
      SymbolicMath::AST::Builder.new(string: expression).ast.value(local_context)
    end
  end
end

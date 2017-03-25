module Keisan
  class Evaluator
    WORD = /[a-zA-Z_]\w*/
    VARIABLE_DEFINITION = /\A\s*(#{WORD})\s*=\s*(.+)\z/
    FUNCTION_DEFINITION = /\A\s*(#{WORD})\s*\(((?:\s*#{WORD}\s*)(?:,\s*#{WORD}\s*)*)\)\s*=\s*(.+)\z/

    attr_reader :calculator

    def initialize(calculator)
      @calculator = calculator
    end

    def evaluate(expression, definitions = {})
      case expression
      when VARIABLE_DEFINITION
        variable_evaluate(expression, definitions)
      when FUNCTION_DEFINITION
        function_evaluate(expression, definitions)
      else
        pure_evaluate(expression, definitions)
      end
    end

    private

    def variable_evaluate(expression, definitions = {})
      match = expression.match VARIABLE_DEFINITION
      name = match[1]
      expression = match[2]
      ast = Keisan::AST::Builder.new(string: expression).ast

      context = calculator.context.spawn_child(definitions)
      unbound_variables = ast.unbound_variables(context)
      unless unbound_variables <= Set.new([name])
        raise Keisan::Exceptions::InvalidExpression.new("Unbound variables found in variable definition")
      end

      calculator.context.register_variable!(name, ast.value(context))
    end

    def function_evaluate(expression, definitions = {})
      match = expression.match FUNCTION_DEFINITION
      name = match[1]
      args = match[2].split(",").map(&:strip)
      expression = match[3]
      ast = Keisan::AST::Builder.new(string: expression).ast

      context = calculator.context.spawn_child(definitions)
      unbound_variables = ast.unbound_variables(context)
      unbound_functions = ast.unbound_functions(context)
      # Ensure the variables are contained within the arguments
      unless unbound_variables <= Set.new(args) && unbound_functions.empty?
        raise Keisan::Exceptions::InvalidExpression.new("Unbound variables found in function definition")
      end

      calculator.context.register_function!(
        name,
        Proc.new do |*received_args|
          unless args.count == received_args.count
            raise Keisan::Exceptions::InvalidFunctionError.new("Invalid number of arguments for #{name} function")
          end

          local = calculator.context.spawn_child(definitions)
          args.each.with_index do |arg, i|
            local.register_variable!(arg, received_args[i])
          end

          ast.value(local)
        end
      )
    end

    def pure_evaluate(expression, definitions = {})
      Keisan::AST::Builder.new(string: expression).ast.value(calculator.context.spawn_child(definitions))
    end
  end
end

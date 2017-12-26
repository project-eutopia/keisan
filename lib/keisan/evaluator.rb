module Keisan
  class Evaluator
    attr_reader :calculator

    def initialize(calculator)
      @calculator = calculator
    end

    def evaluate(expression, definitions = {})
      context = calculator.context.spawn_child(definitions: definitions, transient: true)
      ast = ast(expression)
      last_line = last_line(ast)

      evaluation = ast.evaluated(context)

      if last_line.is_a?(AST::Assignment)
        if last_line.children.first.is_a?(AST::Variable)
          context.variable(last_line.children.first.name).value(context)
        end
      else
        evaluation.value(context)
      end
    end

    def simplify(expression, definitions = {})
      context = calculator.context.spawn_child(definitions: definitions, transient: true)
      ast = AST.parse(expression)
      ast.simplify(context)
    end

    def ast(expression)
      AST.parse(expression)
    end

    private

    def last_line(ast)
      ast.is_a?(AST::MultiLine) ? ast.children.last : ast
    end
  end
end

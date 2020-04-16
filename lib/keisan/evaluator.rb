module Keisan
  class Evaluator
    attr_reader :calculator

    def initialize(calculator)
      @calculator = calculator
    end

    def evaluate(expression, definitions = {})
      context = calculator.context.spawn_child(definitions: definitions, transient: true)
      ast = parse_ast(expression)
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
      ast = parse_ast(expression)
      ast.simplify(context)
    end

    def parse_ast(expression)
      AST.parse(expression).tap do |ast|
        if !calculator.context.allow_multiline && ast.contains_a?(Keisan::AST::MultiLine)
          raise Keisan::Exceptions::InvalidExpression.new("Context does not permit multiline expressions")
        end
        if !calculator.context.allow_blocks && ast.contains_a?(Keisan::AST::Block)
          raise Keisan::Exceptions::InvalidExpression.new("Context does not permit blocks")
        end
      end
    end

    private

    def last_line(ast)
      ast.is_a?(AST::MultiLine) ? ast.children.last : ast
    end
  end
end

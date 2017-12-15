module Keisan
  module AST
    class UnaryMinus < UnaryOperator
      def value(context = nil)
        return -1 * child.value(context)
      end

      def evaluate(context = nil)
        -child.evaluate(context)
      end

      def self.symbol
        :"-"
      end

      def simplify(context = nil)
        context ||= Context.new

        case child
        when Number
          Number.new(-child.value(context)).simplify(context)
        else
          Times.new([
            Number.new(-1),
            child
          ]).simplify(context)
        end
      end

      def differentiate(variable, context = nil)
        context ||= Context.new
        Times.new([
          -1.to_node,
          child.differentiate(variable, context)
        ]).simplify(context)
      end
    end
  end
end

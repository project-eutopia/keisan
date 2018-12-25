module Keisan
  module AST
    class UnaryInverse < UnaryOperator
      def value(context = nil)
        return Rational(1, child.value(context))
      end

      def to_s
        "(#{child.to_s})**(-1)"
      end

      def evaluate(context = nil)
        1.to_node / child.evaluate(context)
      end

      def simplify(context = nil)
        context ||= Context.new

        @children = [child.simplify(context)]
        case child
        when Number
          Number.new(child.value**-1)
        else
          (child ** -1).simplify(context)
        end
      end

      def differentiate(variable, context = nil)
        context ||= Context.new
        Times.new(
          [
            UnaryMinus.new(child.differentiate(variable, context)),
            UnaryInverse.new(
              Exponent.new([
                child.deep_dup, Number.new(2)
              ])
            )
          ]
        ).simplify(context)
      end
    end
  end
end

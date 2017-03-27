module Keisan
  module AST
    class Exponent < ArithmeticOperator
      def self.symbol
        :**
      end

      def blank_value
        1
      end

      def simplify(context = nil)
        context ||= Context.new

        super(context)

        # Reduce to basic binary exponents
        reduced = children.reverse[1..-1].inject(children.last) do |total, child|
          child ** total
        end

        unless reduced.is_a?(AST::Exponent)
          return reduced.simplify(context)
        end

        if reduced.children.count != 2
          raise Keisan::Exceptions::InternalError.new("Exponent should be binary")
        end
        @children = reduced.children

        if children[1].is_a?(AST::Number) && children[1].value(context) == 1
          return children[0]
        end

        if children.all? {|child| child.is_a?(AST::Number)}
          (children[0] ** children[1]).simplify(context)
        else
          self
        end
      end

      def evaluate(context = nil)
        children.reverse[1..-1].inject(children.last.evaluate(context)) {|total, child| child.evaluate(context) ** total}
      end

      def differentiate(variable, context = nil)
        base = children[0].simplified(context)
        exponent = children[1].simplified(context)

        raise Exceptions::NonDifferentiableError.new unless exponent.is_a?(AST::Number)

        node = AST::Times.new(
          [
            exponent,
            AST::Exponent.new([base, AST::Number.new(exponent.value(context) - 1)]),
            base.differentiate(variable, context)
          ]
        ).simplified;
      end

      def polynomial_signature(context = nil)
        base = children[0].simplified(context)
        exponent = children[1].simplified(context)

        return AST::PolynomialSignature.new unless exponent.is_a?(AST::Number)

        base.polynomial_signature(context) ** exponent.value(context)
      end
    end
  end
end

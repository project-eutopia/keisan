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

      # d ( a^b ) = d ( exp(b log(a)) ) = a^b * d (b log(a))
      # = a^b * [ db * log(a) + da * b/a] = da b a^(b-1) + db log(a) a^b
      def differentiate(variable, context = nil)
        context ||= Context.new

        # Reduce to binary form
        unless children.count == 2
          return simplify(context).differentiate(variable, context)
        end

        base     = children[0].simplified(context)
        exponent = children[1].simplified(context)

        # Special simple case where exponent is a pure number
        if exponent.is_a?(AST::Number)
          return (exponent * base.differentiate(variable, context) * base ** (exponent -1)).simplify(context)
        end

        base_diff     = base.differentiate(variable, context)
        exponent_diff = exponent.differentiate(variable, context)

        res = base ** exponent * (
          exponent_diff * AST::Function.new([base], "log") +
          base_diff * exponent / base
        )
        res.simplify(context)
      end
    end
  end
end

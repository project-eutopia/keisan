module Keisan
  module AST
    class Exponent < ArithmeticOperator
      def arity
        (2..2)
      end

      def associativity
        :right
      end

      def self.symbol
        :**
      end

      def blank_value
        1
      end

      def simplify(context = nil)
        super

        if children[1].is_a?(AST::Number) && children[1].value(context) == 1
          return children[0]
        end

        if children.all? {|child| child.is_a?(ConstantLiteral)}
          (children[0] ** children[1]).simplify(context)
        else
          self
        end
      end
    end
  end
end

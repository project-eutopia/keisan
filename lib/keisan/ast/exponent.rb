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
        if children.all? {|child| child.is_a?(ConstantLiteral)}
          children[0] ** children[1]
        else
          self
        end
      end
    end
  end
end

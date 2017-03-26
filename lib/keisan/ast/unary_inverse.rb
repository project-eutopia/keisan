module Keisan
  module AST
    class UnaryInverse < UnaryOperator
      def value(context = nil)
        return Rational(1, child.value(context))
      end

      def to_s
        "(#{child.to_s})**(-1)"
      end

      def simplify(context = nil)
        @children = [child.simplify(context)]
        case child
        when AST::Number
          AST::Number.new(Rational(1,child.value(context))).simplify(context)
        else
          super
        end
      end
    end
  end
end

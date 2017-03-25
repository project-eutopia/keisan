module Keisan
  module AST
    class Modulo < ArithmeticOperator
      def arity
        2..Float::INFINITY
      end

      def self.symbol
        :%
      end

      def value(context = nil)
        children_values = children.map {|child| child.value(context)}
        children_values[1..-1].inject(children_values[0], &:%)
      end
    end
  end
end

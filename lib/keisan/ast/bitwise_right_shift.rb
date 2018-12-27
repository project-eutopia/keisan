module Keisan
  module AST
    class BitwiseRightShift < BitwiseOperator
      def self.symbol
        :>>
      end

      def blank_value
        0
      end

      def evaluate(context = nil)
        children[1..-1].inject(children.first.evaluate(context)) {|total, child| total >> child.evaluate(context)}
      end
    end
  end
end

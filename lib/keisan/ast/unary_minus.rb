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
        when AST::Number
          AST::Number.new(-child.value(context)).simplify(context)
        else
          AST::Times.new([
            AST::Number.new(-1),
            child.simplify(context)
          ])
        end
      end
    end
  end
end

module Keisan
  module AST
    class UnaryIdentity < UnaryOperator
      def value(context = nil)
        child.value(context)
      end

      def evaluate(context = nil)
        child.evaluate(context)
      end

      def self.symbol
        nil
      end

      def simplify(context = nil)
        child.simplify(context)
      end

      def differentiate(variable, context = nil)
        context ||= Context.new
        child.differentiate(variable, context).simplify(context)
      end
    end
  end
end

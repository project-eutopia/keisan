module Keisan
  module AST
    class LogicalLessThanOrEqualTo < LogicalOperator
      def self.symbol
        :"<="
      end

      def evaluate(context = nil)
        children[0].evaluate(context) <= children[1].evaluate(context)
      end

      def value(context = nil)
        children.first.value(context) <= children.last.value(context)
      end
    end
  end
end

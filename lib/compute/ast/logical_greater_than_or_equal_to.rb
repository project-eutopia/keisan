module Compute
  module AST
    class LogicalGreaterThanOrEqualTo < LogicalOperator
      def self.priority
        62
      end

      def arity
        2..2
      end

      def value(context = nil)
        children.first.value(context) >= children.last.value(context)
      end
    end
  end
end

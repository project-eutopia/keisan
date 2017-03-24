module Keisan
  module AST
    class LogicalLessThanOrEqualTo < LogicalOperator
      def self.priority
        52
      end

      def arity
        2..2
      end

      def value(context = nil)
        children.first.value(context) <= children.last.value(context)
      end
    end
  end
end

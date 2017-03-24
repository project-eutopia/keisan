module Compute
  module AST
    class LogicalLessThan < LogicalOperator
      def self.priority
        72
      end

      def arity
        2..2
      end

      def value(context = nil)
        children.first.value(context) < children.last.value(context)
      end
    end
  end
end

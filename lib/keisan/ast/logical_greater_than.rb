module Keisan
  module AST
    class LogicalGreaterThan < LogicalOperator
      def self.priority
        82
      end

      def arity
        2..2
      end

      def value(context = nil)
        children.first.value(context) > children.last.value(context)
      end
    end
  end
end

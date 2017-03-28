module Keisan
  module AST
    class LogicalGreaterThanOrEqualTo < LogicalOperator
      def self.symbol
        :">="
      end

      def value(context = nil)
        children.first.value(context) >= children.last.value(context)
      end
    end
  end
end

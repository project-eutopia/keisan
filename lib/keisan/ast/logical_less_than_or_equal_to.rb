module Keisan
  module AST
    class LogicalLessThanOrEqualTo < LogicalOperator
      def self.symbol
        :"<="
      end

      def value(context = nil)
        children.first.value(context) <= children.last.value(context)
      end
    end
  end
end

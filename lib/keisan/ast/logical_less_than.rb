module Keisan
  module AST
    class LogicalLessThan < LogicalOperator
      def arity
        2..2
      end

      def self.symbol
        :"<"
      end

      def value(context = nil)
        children.first.value(context) < children.last.value(context)
      end
    end
  end
end

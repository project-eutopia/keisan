module Keisan
  module AST
    class LogicalOr < LogicalOperator
      def self.symbol
        :"||"
      end

      def blank_value
        false
      end

      def evaluate(context = nil)
        children[0].evaluate(context).or(children[1].evaluate(context))
      end

      def value(context = nil)
        context ||= Context.new
        children[0].value(context) || children[1].value(context)
      end
    end
  end
end

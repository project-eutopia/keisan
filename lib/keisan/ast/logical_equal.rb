module Keisan
  module AST
    class LogicalEqual < LogicalOperator
      def self.symbol
        :"=="
      end

      def evaluate(context = nil)
        children[0].evaluate(context).equal(children[1].evaluate(context))
      end

      def value(context=nil)
        context ||= Context.new
        children[0].value(context) == children[1].value(context)
      end
    end
  end
end

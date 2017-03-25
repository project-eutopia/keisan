module Keisan
  module AST
    class LogicalNotEqual < LogicalOperator
      def arity
        2..2
      end

      def self.symbol
        :"!="
      end

      def value(context=nil)
        context ||= Context.new
        children[0].value(context) != children[1].value(context)
      end
    end
  end
end

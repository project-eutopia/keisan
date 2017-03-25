module Keisan
  module AST
    class LogicalAnd < LogicalOperator
      def arity
        2..Float::INFINITY
      end

      def self.symbol
        :"&&"
      end

      def blank_value
        true
      end

      def value(context = nil)
        context ||= Keisan::Context.new
        children[0].value(context) && children[1].value(context)
      end
    end
  end
end

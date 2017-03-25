module Keisan
  module AST
    class LogicalAnd < LogicalOperator
      def arity
        2..Float::INFINITY
      end

      def self.symbol
        :"&"
      end

      def blank_value
        true
      end
    end
  end
end

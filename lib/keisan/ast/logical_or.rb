module Keisan
  module AST
    class LogicalOr < LogicalOperator
      def arity
        2..Float::INFINITY
      end

      def self.symbol
        :"|"
      end

      def blank_value
        false
      end
    end
  end
end

module Keisan
  module AST
    class LogicalOr < LogicalOperator
      def self.priority
        12
      end

      def arity
        2..Float::INFINITY
      end

      def symbol
        :"|"
      end

      def blank_value
        false
      end
    end
  end
end

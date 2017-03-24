module Keisan
  module AST
    class LogicalAnd < LogicalOperator
      def self.priority
        22
      end

      def arity
        2..Float::INFINITY
      end

      def symbol
        :"&"
      end

      def blank_value
        true
      end
    end
  end
end

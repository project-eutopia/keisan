module Keisan
  module AST
    class LogicalGreaterThanOrEqualTo < LogicalOperator
      def self.symbol
        :">="
      end

      protected

      def value_operator
        :>=
      end

      def operator
        :>=
      end
    end
  end
end

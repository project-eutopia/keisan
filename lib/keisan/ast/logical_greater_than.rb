module Keisan
  module AST
    class LogicalGreaterThan < LogicalOperator
      def self.symbol
        :">"
      end

      protected

      def value_operator
        :>
      end

      def operator
        :>
      end
    end
  end
end

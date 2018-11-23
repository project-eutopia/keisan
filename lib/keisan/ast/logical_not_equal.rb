module Keisan
  module AST
    class LogicalNotEqual < LogicalOperator
      def self.symbol
        :"!="
      end

      protected

      def value_operator
        :!=
      end

      def operator
        :not_equal
      end
    end
  end
end

module Keisan
  module AST
    class LogicalEqual < LogicalOperator
      def self.symbol
        :"=="
      end

      protected

      def value_operator
        :==
      end

      def operator
        :equal
      end
    end
  end
end

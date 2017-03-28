module Keisan
  module AST
    class BitwiseXor < BitwiseOperator
      def self.symbol
        :"^"
      end

      def blank_value
        0
      end
    end
  end
end

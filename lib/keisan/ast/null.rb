module Keisan
  module AST
    class Null < ConstantLiteral
      def initialize
      end

      def value(context = nil)
        nil
      end

      def true?
        false
      end
    end
  end
end

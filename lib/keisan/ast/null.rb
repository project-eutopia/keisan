module Keisan
  module AST
    class Null < ConstantLiteral
      def initialize
      end

      def value(context = nil)
        nil
      end
    end
  end
end

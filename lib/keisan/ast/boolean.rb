module Keisan
  module AST
    class Boolean < ConstantLiteral
      attr_reader :bool

      def initialize(bool)
        @bool = bool
      end

      def value(context = nil)
        bool
      end
    end
  end
end

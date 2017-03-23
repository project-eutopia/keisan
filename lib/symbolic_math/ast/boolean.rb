module SymbolicMath
  module AST
    class Boolean < Literal
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

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

      def !
        AST::Boolean.new(!bool)
      end

      def and(other)
        case other
        when AST::Boolean
          AST::Boolean.new(bool && other.bool)
        else
          super
        end
      end

      def or(other)
        case other
        when AST::Boolean
          AST::Boolean.new(bool || other.bool)
        else
          super
        end
      end
    end
  end
end

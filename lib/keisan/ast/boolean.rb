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
        Boolean.new(!bool)
      end

      def and(other)
        other = other.to_node
        case other
        when Boolean
          Boolean.new(bool && other.bool)
        else
          super
        end
      end

      def or(other)
        other = other.to_node
        case other
        when Boolean
          Boolean.new(bool || other.bool)
        else
          super
        end
      end
    end
  end
end

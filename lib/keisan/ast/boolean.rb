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

      def true?
        false
      end

      def !
        Boolean.new(!bool)
      end

      def and(other)
        other = other.to_node
        other.is_a?(Boolean) ? Boolean.new(bool && other.bool) : super
      end

      def or(other)
        other = other.to_node
        other.is_a?(Boolean) ? Boolean.new(bool || other.bool) : super
      end

      def equal(other)
        other = other.to_node
        other.is_a?(Boolean) ? Boolean.new(value == other.value) : super
      end

      def not_equal(other)
        other = other.to_node
        other.is_a?(Boolean) ? Boolean.new(value != other.value) : super
      end
    end
  end
end

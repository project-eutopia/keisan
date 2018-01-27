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

      def equal(other)
        other = other.to_node
        other.is_a?(AST::Null) ? Boolean.new(value == other.value) : super
      end

      def not_equal(other)
        other = other.to_node
        other.is_a?(AST::Null) ? Boolean.new(value != other.value) : super
      end
    end
  end
end

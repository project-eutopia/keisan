module Keisan
  module AST
    class Date < ConstantLiteral
      attr_reader :content

      def initialize(content)
        @content = content
      end

      def value(context = nil)
        content
      end

      def +(other)
        other = other.to_node
        case other
        when Number
          self.class.new(value + other.value)
        else
          super
        end
      end

      def to_s
        value.to_s
      end

      def >(other)
        other = other.to_node
        other.is_a?(AST::Date) ? Boolean.new(value > other.value) : super
      end

      def >=(other)
        other = other.to_node
        other.is_a?(AST::Date) ? Boolean.new(value >= other.value) : super
      end

      def <(other)
        other = other.to_node
        other.is_a?(AST::Date) ? Boolean.new(value < other.value) : super
      end

      def <=(other)
        other = other.to_node
        other.is_a?(AST::Date) ? Boolean.new(value <= other.value) : super
      end

      def equal(other)
        other = other.to_node
        other.is_a?(AST::Date) ? Boolean.new(value == other.value) : super
      end

      def not_equal(other)
        other = other.to_node
        other.is_a?(AST::Date) ? Boolean.new(value != other.value) : super
      end
    end
  end
end

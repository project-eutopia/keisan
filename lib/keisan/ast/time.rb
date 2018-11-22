module Keisan
  module AST
    class Time < ConstantLiteral
      attr_reader :time

      def initialize(time)
        @time = time
      end

      def value(context = nil)
        time
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
        value.strftime("%Y-%m-%d %H:%M:%S")
      end

      def >(other)
        other = other.to_node
        other.is_a?(AST::Time) ? Boolean.new(value > other.value) : super
      end

      def >=(other)
        other = other.to_node
        other.is_a?(AST::Time) ? Boolean.new(value >= other.value) : super
      end

      def <(other)
        other = other.to_node
        other.is_a?(AST::Time) ? Boolean.new(value < other.value) : super
      end

      def <=(other)
        other = other.to_node
        other.is_a?(AST::Time) ? Boolean.new(value <= other.value) : super
      end

      def equal(other)
        other = other.to_node
        other.is_a?(AST::Time) ? Boolean.new(value == other.value) : super
      end

      def not_equal(other)
        other = other.to_node
        other.is_a?(AST::Time) ? Boolean.new(value != other.value) : super
      end
    end
  end
end

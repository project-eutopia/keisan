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

      def equal(other)
        other = other.to_node
        case other
        when AST::Boolean
          Boolean.new(value == other.value)
        else
          super
        end
      end

      def not_equal(other)
        other = other.to_node
        case other
        when AST::Boolean
          Boolean.new(value != other.value)
        else
          super
        end
      end
    end
  end
end

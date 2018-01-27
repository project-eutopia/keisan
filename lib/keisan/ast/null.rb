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
        case other
        when AST::Null
          Boolean.new(value == other.value)
        else
          super
        end
      end

      def not_equal(other)
        other = other.to_node
        case other
        when AST::Null
          Boolean.new(value != other.value)
        else
          super
        end
      end
    end
  end
end

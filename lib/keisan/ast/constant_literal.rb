module Keisan
  module AST
    class ConstantLiteral < Literal
      def evaluate(context = nil)
        self
      end

      def ==(other)
        case other
        when ConstantLiteral
          value == other.value
        else
          false
        end
      end

      def to_s
        case value
        when Rational
          "(#{value.to_s})"
        else
          value.to_s
        end
      end

      def is_constant?
        true
      end
    end
  end
end

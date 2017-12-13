module Keisan
  module AST
    class ConstantLiteral < Literal
      def evaluate(context = nil)
        self
      end

      def to_s
        case value
        when Rational
          "(#{value.to_s})"
        else
          value.to_s
        end
      end
    end
  end
end

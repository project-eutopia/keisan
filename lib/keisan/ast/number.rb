module Keisan
  module AST
    class Number < ConstantLiteral
      attr_reader :number

      def initialize(number)
        @number = number
      end

      def value(context = nil)
        number
      end

      def -@
        AST::Number.new(-value)
      end

      def +@
        AST::Number.new(value)
      end

      def +(other)
        case other
        when AST::Number
          AST::Number.new(value + other.value)
        else
          super
        end
      end

      def *(other)
        case other
        when AST::Number
          AST::Number.new(value * other.value)
        else
          super
        end
      end

      def **(other)
        case other
        when AST::Number
          AST::Number.new(value ** other.value)
        else
          raise Keisan::Exceptions::TypeError.new("#{other}'s type is invalid, #{other.class}")
        end
      end

      def simplify(context = nil)
        case number
        when Rational
          if number.denominator == 1
            @number = number.numerator
          end
        end

        self
      end
    end
  end
end

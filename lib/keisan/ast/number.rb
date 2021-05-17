module Keisan
  module AST
    class Number < ConstantLiteral
      attr_reader :number

      def initialize(number)
        @number = number
        # Reduce the number if possible
        case @number
        when Rational
          @number = @number.numerator if @number.denominator == 1
        end
      end

      def value(context = nil)
        number
      end

      def -@
        Number.new(-value)
      end

      def +@
        Number.new(value)
      end

      def +(other)
        other = other.to_node
        case other
        when Number
          Number.new(value + other.value)
        when Date
          Date.new(other.value + value)
        when Time
          Time.new(other.value + value)
        else
          super
        end
      end

      def -(other)
        self + (-other.to_node)
      end

      def *(other)
        other = other.to_node
        case other
        when Number
          Number.new(value * other.value)
        else
          super
        end
      end

      def /(other)
        other = other.to_node
        case other
        when Number
          Number.new(Rational(value, other.value))
        else
          super
        end
      end

      def **(other)
        other = other.to_node
        case other
        when Number
          Number.new(value ** other.value)
        else
          super
        end
      end

      def %(other)
        other = other.to_node
        case other
        when Number
          Number.new(value % other.value)
        else
          super
        end
      end

      def &(other)
        other = other.to_node
        case other
        when Number
          Number.new(value & other.value)
        else
          super
        end
      end

      def ~
        Number.new(~value)
      end

      def ^(other)
        other = other.to_node
        case other
        when Number
          Number.new(value ^ other.value)
        else
          super
        end
      end

      def |(other)
        other = other.to_node
        case other
        when Number
          Number.new(value | other.value)
        else
          super
        end
      end

      def <<(other)
        other = other.to_node
        case other
        when Number
          Number.new(value << other.value)
        else
          super
        end
      end

      def >>(other)
        other = other.to_node
        case other
        when Number
          Number.new(value >> other.value)
        else
          super
        end
      end

      def >(other)
        other = other.to_node
        case other
        when Number
          Boolean.new(value > other.value)
        else
          super
        end
      end

      def >=(other)
        other = other.to_node
        case other
        when Number
          Boolean.new(value >= other.value)
        else
          super
        end
      end

      def <(other)
        other = other.to_node
        case other
        when Number
          Boolean.new(value < other.value)
        else
          super
        end
      end

      def <=(other)
        other = other.to_node
        case other
        when Number
          Boolean.new(value <= other.value)
        else
          super
        end
      end

      def equal(other)
        other = other.to_node
        case other
        when Number
          Boolean.new(value == other.value)
        else
          super
        end
      end

      def not_equal(other)
        other = other.to_node
        case other
        when Number
          Boolean.new(value != other.value)
        else
          super
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

      def differentiate(variable, context = nil)
        0.to_node
      end
    end
  end
end

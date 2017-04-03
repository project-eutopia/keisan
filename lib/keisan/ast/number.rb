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
        other = other.to_node
        case other
        when AST::Number
          AST::Number.new(value + other.value)
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
        when AST::Number
          AST::Number.new(value * other.value)
        else
          super
        end
      end

      def /(other)
        other = other.to_node
        case other
        when AST::Number
          AST::Number.new(Rational(value, other.value))
        else
          super
        end
      end

      def **(other)
        other = other.to_node
        case other
        when AST::Number
          AST::Number.new(value ** other.value)
        else
          super
        end
      end

      def %(other)
        other = other.to_node
        case other
        when AST::Number
          AST::Number.new(value % other.value)
        else
          super
        end
      end

      def &(other)
        other = other.to_node
        case other
        when AST::Number
          AST::Number.new(value & other.value)
        else
          super
        end
      end

      def ~
        AST::Number.new(~value)
      end

      def ^(other)
        other = other.to_node
        case other
        when AST::Number
          AST::Number.new(value ^ other.value)
        else
          super
        end
      end

      def |(other)
        other = other.to_node
        case other
        when AST::Number
          AST::Number.new(value | other.value)
        else
          super
        end
      end

      def >(other)
        other = other.to_node
        case other
        when AST::Number
          AST::Boolean.new(value > other.value)
        else
          super
        end
      end

      def >=(other)
        other = other.to_node
        case other
        when AST::Number
          AST::Boolean.new(value >= other.value)
        else
          super
        end
      end

      def <(other)
        other = other.to_node
        case other
        when AST::Number
          AST::Boolean.new(value < other.value)
        else
          super
        end
      end

      def <=(other)
        other = other.to_node
        case other
        when AST::Number
          AST::Boolean.new(value <= other.value)
        else
          super
        end
      end

      def equal(other)
        other = other.to_node
        case other
        when AST::Number
          AST::Boolean.new(value == other.value)
        else
          super
        end
      end

      def not_equal(other)
        other = other.to_node
        case other
        when AST::Number
          AST::Boolean.new(value != other.value)
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

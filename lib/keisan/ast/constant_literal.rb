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

      def +(other)
        if other.is_constant?
          raise Keisan::Exceptions::InvalidExpression.new("Cannot add #{self.class} to #{other.class}")
        else
          super
        end
      end

      def -(other)
        if other.is_constant?
          raise Keisan::Exceptions::InvalidExpression.new("Cannot subtract #{self.class} from #{other.class}")
        else
          super
        end
      end

      def *(other)
        if other.is_constant?
          raise Keisan::Exceptions::InvalidExpression.new("Cannot multiply #{self.class} and #{other.class}")
        else
          super
        end
      end

      def /(other)
        if other.is_constant?
          raise Keisan::Exceptions::InvalidExpression.new("Cannot divide #{self.class} and #{other.class}")
        else
          super
        end
      end

      def %(other)
        if other.is_constant?
          raise Keisan::Exceptions::InvalidExpression.new("Cannot modulo #{self.class} and #{other.class}")
        else
          super
        end
      end

      def !
        raise Keisan::Exceptions::InvalidExpression.new("Cannot take logical not of #{self.class}")
      end

      def ~
        raise Keisan::Exceptions::InvalidExpression.new("Cannot take bitwise not of #{self.class}")
      end

      def +@
        raise Keisan::Exceptions::InvalidExpression.new("Cannot take unary plus of #{self.class}")
      end

      def -@
        raise Keisan::Exceptions::InvalidExpression.new("Cannot take unary minus of #{self.class}")
      end

      def **(other)
        if other.is_constant?
          raise Keisan::Exceptions::InvalidExpression.new("Cannot exponentiate #{self.class} and #{other.class}")
        else
          super
        end
      end

      def &(other)
        if other.is_constant?
          raise Keisan::Exceptions::InvalidExpression.new("Cannot bitwise and #{self.class} and #{other.class}")
        else
          super
        end
      end

      def ^(other)
        if other.is_constant?
          raise Keisan::Exceptions::InvalidExpression.new("Cannot bitwise xor #{self.class} and #{other.class}")
        else
          super
        end
      end

      def |(other)
        if other.is_constant?
          raise Keisan::Exceptions::InvalidExpression.new("Cannot bitwise or #{self.class} and #{other.class}")
        else
          super
        end
      end

      def <<(other)
        if other.is_constant?
          raise Keisan::Exceptions::InvalidExpression.new("Cannot bitwise left shift #{self.class} and #{other.class}")
        else
          super
        end
      end

      def >>(other)
        if other.is_constant?
          raise Keisan::Exceptions::InvalidExpression.new("Cannot bitwise right shift #{self.class} and #{other.class}")
        else
          super
        end
      end

      def >(other)
        if other.is_constant?
          raise Keisan::Exceptions::InvalidExpression.new("Cannot compute #{self.class} > #{other.class}")
        else
          super
        end
      end

      def >=(other)
        if other.is_constant?
          raise Keisan::Exceptions::InvalidExpression.new("Cannot compute #{self.class} >= #{other.class}")
        else
          super
        end
      end

      def <(other)
        if other.is_constant?
          raise Keisan::Exceptions::InvalidExpression.new("Cannot compute #{self.class} < #{other.class}")
        else
          super
        end
      end

      def <=(other)
        if other.is_constant?
          raise Keisan::Exceptions::InvalidExpression.new("Cannot compute #{self.class} <= #{other.class}")
        else
          super
        end
      end

      def equal(other)
        other.is_constant? ? Boolean.new(false) : super
      end

      def not_equal(other)
        other.is_constant? ? Boolean.new(true) : super
      end

      def and(other)
        if other.is_constant?
          raise Keisan::Exceptions::InvalidExpression.new("Cannot logical and #{self.class} and #{other.class}")
        else
          super
        end
      end

      def or(other)
        if other.is_constant?
          raise Keisan::Exceptions::InvalidExpression.new("Cannot logical or #{self.class} and #{other.class}")
        else
          super
        end
      end
    end
  end
end

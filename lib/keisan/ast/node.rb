module Keisan
  module AST
    class Node
      def value(context = nil)
        raise Exceptions::NotImplementedError.new
      end

      def unbound_variables(context = nil)
        Set.new
      end

      def unbound_functions(context = nil)
        Set.new
      end

      def well_defined?(context = nil)
        unbound_variables(context).empty? && unbound_functions(context).empty?
      end

      def deep_dup
        dup
      end

      def simplified(context = nil)
        deep_dup.simplify(context)
      end

      def simplify(context = nil)
        self
      end

      def evaluated(context = nil)
        deep_dup.evaluate(context)
      end

      def evaluate(context = nil)
        value(context)
      end

      def evaluate_assignments(context = nil)
        self
      end

      def differentiate(variable, context = nil)
        raise Exceptions::NonDifferentiableError.new
      end

      def replace(variable, replacement)
        self
      end

      def coerce(other)
        [other.to_node, self]
      end

      def to_node
        self
      end

      def to_cell
        AST::Cell.new(self)
      end

      # Will only return False for AST::Boolean(false) and AST::Null
      def true?
        true
      end

      def false?
        !true?
      end

      def +(other)
        Plus.new(
          [self, other.to_node]
        )
      end

      def -(other)
        Plus.new(
          [self, UnaryMinus.new(other.to_node)]
        )
      end

      def *(other)
        Times.new(
          [self, other.to_node]
        )
      end

      def /(other)
        Times.new(
          [self, UnaryInverse.new(other.to_node)]
        )
      end

      def %(other)
        Modulo.new(
          [self, other.to_node]
        )
      end

      def !
        UnaryLogicalNot.new(self)
      end

      def ~
        UnaryBitwiseNot.new(self)
      end

      def +@
        self
      end

      def -@
        UnaryMinus.new(self)
      end

      def **(other)
        Exponent.new([self, other.to_node])
      end

      def &(other)
        BitwiseAnd.new([self, other.to_node])
      end

      def ^(other)
        BitwiseXor.new([self, other.to_node])
      end

      def |(other)
        BitwiseOr.new([self, other.to_node])
      end

      def >(other)
        LogicalGreaterThan.new([self, other.to_node])
      end

      def >=(other)
        LogicalGreaterThanOrEqualTo.new([self, other.to_node])
      end

      def <(other)
        LogicalLessThan.new([self, other.to_node])
      end

      def <=(other)
        LogicalLessThanOrEqualTo.new([self, other.to_node])
      end

      def equal(other)
        LogicalEqual.new([self, other.to_node])
      end

      def not_equal(other)
        LogicalNotEqual.new([self, other.to_node])
      end

      def and(other)
        LogicalAnd.new([self, other.to_node])
      end

      def or(other)
        LogicalOr.new([self, other.to_node])
      end
    end
  end
end

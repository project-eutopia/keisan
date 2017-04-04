module Keisan
  module AST
    class Node
      def value(context = nil)
        raise Keisan::Exceptions::NotImplementedError.new
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

      def evaluate(context = nil)
        self
      end

      def differentiate(variable, context = nil)
        raise Keisan::Exceptions::NonDifferentiableError.new
      end

      def substitute(**definitions)
        context = Keisan::Context.new.spawn_child(definitions: definitions)
        evaluate(context)
      end

      def coerce(other)
        [other.to_node, self]
      end

      def to_node
        self
      end

      def +(other)
        AST::Plus.new(
          [self, other.to_node]
        )
      end

      def -(other)
        AST::Plus.new(
          [self, AST::UnaryMinus.new(other.to_node)]
        )
      end

      def *(other)
        AST::Times.new(
          [self, other.to_node]
        )
      end

      def /(other)
        AST::Times.new(
          [self, AST::UnaryInverse.new(other.to_node)]
        )
      end

      def %(other)
        AST::Modulo.new(
          [self, other.to_node]
        )
      end

      def !
        AST::LogicalNot.new(self)
      end

      def ~
        AST::UnaryBitwiseNot.new(self)
      end

      def +@
        self
      end

      def -@
        AST::UnaryMinus.new(self)
      end

      def **(other)
        AST::Exponent.new([self, other.to_node])
      end

      def &(other)
        AST::BitwiseAnd.new([self, other.to_node])
      end

      def ^(other)
        AST::BitwiseXor.new([self, other.to_node])
      end

      def |(other)
        AST::BitwiseOr.new([self, other.to_node])
      end

      def >(other)
        AST::LogicalGreaterThan.new([self, other.to_node])
      end

      def >=(other)
        AST::LogicalGreaterThanOrEqualTo.new([self, other.to_node])
      end

      def <(other)
        AST::LogicalLessThan.new([self, other.to_node])
      end

      def <=(other)
        AST::LogicalLessThanOrEqualTo.new([self, other.to_node])
      end

      def equal(other)
        AST::LogicalEqual.new([self, other.to_node])
      end

      def not_equal(other)
        AST::LogicalNotEqual.new([self, other.to_node])
      end

      def and(other)
        AST::LogicalAnd.new([self, other.to_node])
      end

      def or(other)
        AST::LogicalOr.new([self, other.to_node])
      end
    end
  end
end

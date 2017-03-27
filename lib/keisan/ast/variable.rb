module Keisan
  module AST
    class Variable < Literal
      attr_reader :name

      def initialize(name)
        @name = name
      end

      def value(context = nil)
        context = Keisan::Context.new if context.nil?
        context.variable(name)
      end

      def unbound_variables(context = nil)
        context ||= Keisan::Context.new
        context.has_variable?(name) ? Set.new : Set.new([name])
      end

      def ==(other)
        name == other.name
      end

      def to_s
        name.to_s
      end

      def evaluate(context = nil)
        context ||= Keisan::Context.new
        if context.has_variable?(name)
          context.variable(name).to_node.evaluate(context)
        else
          self
        end
      end

      def simplify(context = nil)
        context ||= Keisan::Context.new
        if context.has_variable?(name)
          context.variable(name).to_node.simplify(context)
        else
          self
        end
      end

      def differentiate(variable, context = nil)
        context ||= Keisan::Context.new

        if name == variable.name && !context.has_variable?(name)
          AST::Number.new(1)
        else
          AST::Number.new(0)
        end
      end

      def polynomial_signature(context = nil)
        context ||= Keisan::Context.new
        AST::PolynomialSignature.new(
          context.has_variable?(name) ? {} : {name => 1}
        )
      end
    end
  end
end

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
    end
  end
end

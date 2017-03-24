module Compute
  module AST
    class Variable < Literal
      attr_reader :name

      def initialize(name)
        @name = name
      end

      def value(context = nil)
        context = Compute::Context.new if context.nil?
        context.variable(name)
      end
    end
  end
end

module SymbolicMath
  module AST
    class Variable < Literal
      attr_reader :name

      def initialize(name)
        @name = name
      end

      def value(context)
        context.fetch(name)
      end
    end
  end
end

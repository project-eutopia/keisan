module SymbolicMath
  module AST
    class Indexing < UnaryOperator
      attr_reader :arguments

      def initialize(child, arguments = [])
        @children = [child]
        @arguments = arguments
      end

      def value(context = nil)
        return children.first.value(context).send(:[], *arguments.map {|arg| arg.value(context)})
      end
    end
  end
end

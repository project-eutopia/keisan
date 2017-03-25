module Keisan
  module AST
    class Indexing < UnaryOperator
      attr_reader :arguments

      def initialize(child, arguments = [])
        @children = [child]
        @arguments = arguments
      end

      def value(context = nil)
        return child.value(context).send(:[], *arguments.map {|arg| arg.value(context)})
      end

      def to_s
        "#{child.to_s}[#{arguments.map(&:to_s).join(',')}]"
      end
    end
  end
end

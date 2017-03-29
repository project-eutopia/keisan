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
        "(#{child.to_s})[#{arguments.map(&:to_s).join(',')}]"
      end

      def simplify(context = nil)
        @arguments = arguments.map {|argument| argument.simplify(context)}
        @children = [child.simplify(context)]

        case child
        when AST::List
          if @arguments.size == 1 && @arguments.first.is_a?(AST::Number)
            return child.children[@arguments.first.value(context)].simplify(context)
          end
        end

        self
      end
    end
  end
end

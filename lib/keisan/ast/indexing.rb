module Keisan
  module AST
    class Indexing < UnaryOperator
      attr_reader :indexes

      def initialize(child, indexes = [])
        @children = [child]
        @indexes = indexes
      end

      def value(context = nil)
        return child.value(context).send(:[], *indexes.map {|index| index.value(context)})
      end

      def to_s
        "(#{child.to_s})[#{indexes.map(&:to_s).join(',')}]"
      end

      def evaluate(context = nil)
        context ||= Context.new
        @children = children.map {|child| child.evaluate(context)}
        @indexes = indexes.map {|index| index.evaluate(context)}

        case child
        when List
          if @indexes.size == 1 && @indexes.first.is_a?(Number)
            return child.children[@indexes.first.value(context)].evaluate(context)
          end
        end

        self
      end

      def simplify(context = nil)
        context ||= Context.new

        @indexes = indexes.map {|index| index.simplify(context)}
        @children = [child.simplify(context)]

        case child
        when List
          if @indexes.size == 1 && @indexes.first.is_a?(Number)
            return child.children[@indexes.first.value(context)].simplify(context)
          end
        end

        self
      end

      def replace(variable, replacement)
        super
        @indexes = indexes.map {|index| index.replace(variable, replacement)}
      end
    end
  end
end

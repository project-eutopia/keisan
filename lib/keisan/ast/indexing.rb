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

      def evaluate_assignments(context = nil)
        self
      end

      def evaluate(context = nil)
        context ||= Context.new
        @children = children.map {|child| child.evaluate(context)}
        @indexes = indexes.map {|index| index.evaluate(context)}

        if list = extract_list
          list.children[@indexes.first.value(context)]
        else
          self
        end
      end

      def simplify(context = nil)
        context ||= Context.new

        @indexes = indexes.map {|index| index.simplify(context)}
        @children = [child.simplify(context)]

        if list = extract_list
          Cell.new(list.children[@indexes.first.value(context)].simplify(context))
        else
          self
        end
      end

      def replace(variable, replacement)
        super
        @indexes = indexes.map {|index| index.replace(variable, replacement)}
      end

      private

      def extract_list
        if child.is_a?(List)
          child
        elsif child.is_a?(Cell) && child.node.is_a?(List)
          child.node
        else
          nil
        end
      end
    end
  end
end

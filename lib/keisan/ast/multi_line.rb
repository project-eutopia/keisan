module Keisan
  module AST
    class MultiLine < Parent
      def value(context = nil)
        context ||= Context.new
        evaluate(context).value(context)
      end

      def evaluate_assignments(context = nil)
        self
      end

      def evaluate(context = nil)
        context ||= Context.new
        @children = children.map {|child| child.evaluate(context)}
        @children.last
      end

      def simplify(context = nil)
        evaluate(context)
      end

      def to_s
        children.map(&:to_s).join(";")
      end
    end
  end
end

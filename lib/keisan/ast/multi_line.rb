module Keisan
  module AST
    class MultiLine < Parent
      def value(context = nil)
        context ||= Keisan::Context.new
        evaluate(context).value(context)
      end

      def evaluate_assignments(context = nil)
        context ||= Context.new
        @children = children.map do |child|
          child.evaluate_assignments(context)
        end
        self
      end

      def evaluate(context = nil)
        context ||= Keisan::Context.new
        @children = children.map {|child| child.evaluate(context)}
        @children.last
      end

      def simplify(context = nil)
        context ||= Keisan::Context.new
        evaluate(context)
      end

      def to_s
        children.map(&:to_s).join(";")
      end
    end
  end
end

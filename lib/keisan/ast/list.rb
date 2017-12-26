module Keisan
  module AST
    class List < Parent
      def initialize(children = [])
        super(children)
        cellify!
      end

      def evaluate(context = nil)
        context ||= Context.new
        super(context)
        cellify!
        self
      end

      def simplify(context = nil)
        context ||= Context.new
        super(context)
        cellify!
        self
      end

      def value(context = nil)
        context ||= Context.new
        children.map {|child| child.value(context)}
      end

      def to_s
        "[#{children.map(&:to_s).join(',')}]"
      end

      private

      def cellify!
        @children = @children.map do |child|
          child.is_a?(Cell) ? child : Cell.new(child)
        end
      end
    end
  end
end

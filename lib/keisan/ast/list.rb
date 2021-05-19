module Keisan
  module AST
    class List < Parent
      def initialize(children = [])
        super(children)
      end

      def evaluate(context = nil)
        return self if frozen?
        context ||= Context.new
        @children = children.map {|child| child.is_a?(Cell) ? child : child.evaluate(context)}
        self
      end

      def simplify(context = nil)
        evaluate(context)
      end

      def value(context = nil)
        context ||= Context.new
        children.map {|child| child.value(context)}
      end

      def to_s
        "[#{children.map(&:to_s).join(',')}]"
      end

      def to_a
        @children.map(&:value)
      end

      def to_cell
        AST::Cell.new(
          self.class.new(
            @children.map(&:to_cell)
          )
        )
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

module Keisan
  module AST
    class Times < ArithmeticOperator
      def initialize(children = [], parsing_operators = [])
        super
        convert_divide_to_inverse!(parsing_operators)
      end

      def self.symbol
        :*
      end

      def blank_value
        1
      end

      def evaluate(context = nil)
        children[1..-1].inject(children.first.evaluate(context)) {|total, child| total * child.evaluate(context)}
      end

      def simplify(context = nil)
        context ||= Context.new

        super(context)

        # Commutative, so pull in operands of any `Times` operators
        @children = children.inject([]) do |new_children, cur_child|
          case cur_child
          when Times
            new_children + cur_child.children
          else
            new_children << cur_child
          end
        end

        constants, non_constants = *children.partition {|child| child.is_a?(Number)}
        constant = constants.inject(Number.new(1), &:*).simplify(context)

        return Number.new(0) if constant.value(context) == 0

        if non_constants.empty?
          constant
        else
          @children = constant.value(context) == 1 ? [] : [constant]
          @children += non_constants

          return @children.first.simplify(context) if @children.size == 1

          self
        end
      end

      def differentiate(variable, context = nil)
        # Product rule
        Plus.new(
          children.map.with_index do |child,i|
            Times.new(
              children.slice(0,i) + [child.differentiate(variable, context)] + children.slice(i+1,children.size)
            )
          end
        ).simplify(context)
      end

      private

      def convert_divide_to_inverse!(parsing_operators)
        parsing_operators.each.with_index do |parsing_operator, index|
          if parsing_operator.is_a?(Parsing::Divide)
            @children[index+1] = UnaryInverse.new(@children[index+1])
          end
        end
      end
    end
  end
end

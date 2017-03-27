module Keisan
  module AST
    class Plus < ArithmeticOperator
      def initialize(children = [], parsing_operators = [])
        super
        convert_minus_to_plus!
      end

      def self.symbol
        :+
      end

      def blank_value
        0
      end

      def value(context = nil)
        children_values = children.map {|child| child.value(context)}
        # Special case of string concatenation
        if children_values.all? {|child| child.is_a?(::String)}
          children_values.join
        # Special case of array concatenation
        elsif children_values.all? {|child| child.is_a?(::Array)}
          children_values.inject([], &:+)
        else
          children_values.inject(0, &:+)
        end
      end

      def evaluate(context = nil)
        children[1..-1].inject(children.first.evaluate(context)) {|total, child| total + child.evaluate(context)}
      end

      def simplify(context = nil)
        context ||= Context.new

        super(context)

        # Commutative, so pull in operands of any `Plus` operators
        @children = children.inject([]) do |new_children, cur_child|
          case cur_child
          when AST::Plus
            new_children + cur_child.children
          else
            new_children << cur_child
          end
        end

        constants, non_constants = *children.partition {|child| child.is_a?(AST::Number)}
        constant = constants.inject(AST::Number.new(0), &:+).simplify(context)

        if non_constants.empty?
          constant
        else
          @children = constant.value(context) == 0 ? [] : [constant]
          @children += non_constants

          return @children.first.simplify(context) if @children.size == 1

          self
        end
      end

      def differentiate(variable)
        AST::Plus.new(children.map {|child| child.differentiate(variable)}).simplified
      end

      private

      def convert_minus_to_plus!
        @parsing_operators.each.with_index do |parsing_operator, index|
          if parsing_operator.is_a?(Keisan::Parsing::Minus)
            @children[index+1] = Keisan::AST::UnaryMinus.new(@children[index+1])
          end
        end
      end
    end
  end
end

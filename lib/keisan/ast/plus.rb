module Keisan
  module AST
    class Plus < ArithmeticOperator
      def initialize(children = [], parsing_operators = [])
        super
        convert_minus_to_plus!
      end

      def self.priority
        10
      end

      def arity
        2..Float::INFINITY
      end

      def symbol
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
        else
          children_values.inject(0, &:+)
        end
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

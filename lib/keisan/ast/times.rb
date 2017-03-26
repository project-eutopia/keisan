module Keisan
  module AST
    class Times < ArithmeticOperator
      def initialize(children = [], parsing_operators = [])
        super
        convert_divide_to_inverse!
      end

      def arity
        2..Float::INFINITY
      end

      def self.symbol
        :*
      end

      def blank_value
        1
      end

      def simplify(context = nil)
        super
        constants, non_constants = *children.partition {|child| child.is_a?(ConstantLiteral)}
        constant = constants.inject(AST::Number.new(1), &:*)

        return Keisan::AST::Number.new(0) if constant.value == 0

        if non_constants.empty?
          constant
        else
          @children = constant.value == 1 ? [] : [constant]
          @children += non_constants

          return @children.first if @children.size == 1

          self
        end
      end

      private

      def convert_divide_to_inverse!
        @parsing_operators.each.with_index do |parsing_operator, index|
          if parsing_operator.is_a?(Keisan::Parsing::Divide)
            @children[index+1] = Keisan::AST::UnaryInverse.new(@children[index+1])
          end
        end
      end
    end
  end
end

module Compute
  module AST
    class Times < ArithmeticOperator
      def initialize(children = [], parsing_operators = [])
        super
        convert_divide_to_inverse!
      end

      def self.priority
        20
      end

      def arity
        2..Float::INFINITY
      end

      def symbol
        :*
      end

      def blank_value
        1
      end

      private

      def convert_divide_to_inverse!
        @parsing_operators.each.with_index do |parsing_operator, index|
          if parsing_operator.is_a?(Compute::Parsing::Divide)
            @children[index+1] = Compute::AST::UnaryInverse.new(@children[index+1])
          end
        end
      end
    end
  end
end

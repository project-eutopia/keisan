module SymbolicMath
  module AST
    class Times < Operator
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

      def value(context = nil)
        children.inject(1) do |product, child|
          product * child.value(context)
        end
      end

      private

      def convert_divide_to_inverse!
        @parsing_operators.each.with_index do |parsing_operator, index|
          if parsing_operator.is_a?(SymbolicMath::Parsing::Divide)
            @children[index+1] = SymbolicMath::AST::UnaryInverse.new(@children[index+1])
          end
        end
      end
    end
  end
end

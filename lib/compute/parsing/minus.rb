module Compute
  module Parsing
    class Minus < ArithmeticOperator
      def node_class
        Compute::AST::Plus
      end
    end
  end
end

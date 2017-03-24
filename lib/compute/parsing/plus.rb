module Compute
  module Parsing
    class Plus < ArithmeticOperator
      def node_class
        Compute::AST::Plus
      end
    end
  end
end

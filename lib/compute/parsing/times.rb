module Compute
  module Parsing
    class Times < ArithmeticOperator
      def node_class
        Compute::AST::Times
      end
    end
  end
end

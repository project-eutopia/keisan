module Compute
  module Parsing
    class Divide < ArithmeticOperator
      def node_class
        Compute::AST::Times
      end
    end
  end
end

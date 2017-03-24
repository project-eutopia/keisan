module Compute
  module Parsing
    class Exponent < ArithmeticOperator
      def node_class
        Compute::AST::Exponent
      end
    end
  end
end

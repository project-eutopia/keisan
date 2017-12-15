module Keisan
  module Parsing
    class Exponent < ArithmeticOperator
      def node_class
        AST::Exponent
      end
    end
  end
end

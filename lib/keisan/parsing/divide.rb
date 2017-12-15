module Keisan
  module Parsing
    class Divide < ArithmeticOperator
      def node_class
        AST::Times
      end
    end
  end
end

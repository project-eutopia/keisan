module Keisan
  module Parsing
    class Times < ArithmeticOperator
      def node_class
        AST::Times
      end
    end
  end
end

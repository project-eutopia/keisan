module Keisan
  module Parsing
    class Minus < ArithmeticOperator
      def node_class
        AST::Plus
      end
    end
  end
end

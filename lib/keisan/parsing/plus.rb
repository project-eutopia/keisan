module Keisan
  module Parsing
    class Plus < ArithmeticOperator
      def node_class
        AST::Plus
      end
    end
  end
end

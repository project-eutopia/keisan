module Keisan
  module Parsing
    class Modulo < ArithmeticOperator
      def node_class
        AST::Modulo
      end
    end
  end
end

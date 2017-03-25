module Keisan
  module Parsing
    class Modulo < ArithmeticOperator
      def node_class
        Keisan::AST::Modulo
      end
    end
  end
end

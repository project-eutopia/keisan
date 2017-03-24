module Keisan
  module Parsing
    class Exponent < ArithmeticOperator
      def node_class
        Keisan::AST::Exponent
      end
    end
  end
end

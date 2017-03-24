module Keisan
  module Parsing
    class Minus < ArithmeticOperator
      def node_class
        Keisan::AST::Plus
      end
    end
  end
end

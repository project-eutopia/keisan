module Keisan
  module Parsing
    class Divide < ArithmeticOperator
      def node_class
        Keisan::AST::Times
      end
    end
  end
end

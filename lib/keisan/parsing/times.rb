module Keisan
  module Parsing
    class Times < ArithmeticOperator
      def node_class
        Keisan::AST::Times
      end
    end
  end
end

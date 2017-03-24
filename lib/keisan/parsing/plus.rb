module Keisan
  module Parsing
    class Plus < ArithmeticOperator
      def node_class
        Keisan::AST::Plus
      end
    end
  end
end

module Keisan
  module Parsing
    class UnaryMinus < UnaryOperator
      def node_class
        Keisan::AST::UnaryMinus
      end
    end
  end
end

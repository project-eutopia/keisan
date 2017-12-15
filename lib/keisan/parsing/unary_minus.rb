module Keisan
  module Parsing
    class UnaryMinus < UnaryOperator
      def node_class
        AST::UnaryMinus
      end
    end
  end
end

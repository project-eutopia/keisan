module Compute
  module Parsing
    class UnaryMinus < UnaryOperator
      def node_class
        Compute::AST::UnaryMinus
      end
    end
  end
end

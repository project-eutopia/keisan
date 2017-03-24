module Compute
  module Parsing
    class UnaryPlus < UnaryOperator
      def node_class
        Compute::AST::UnaryPlus
      end
    end
  end
end

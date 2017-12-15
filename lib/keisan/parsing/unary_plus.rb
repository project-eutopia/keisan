module Keisan
  module Parsing
    class UnaryPlus < UnaryOperator
      def node_class
        AST::UnaryPlus
      end
    end
  end
end

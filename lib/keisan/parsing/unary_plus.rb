module Keisan
  module Parsing
    class UnaryPlus < UnaryOperator
      def node_class
        Keisan::AST::UnaryPlus
      end
    end
  end
end

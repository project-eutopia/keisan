module Keisan
  module Parsing
    class BitwiseNot < UnaryOperator
      def node_class
        AST::UnaryBitwiseNot
      end
    end
  end
end

module Keisan
  module Parsing
    class BitwiseNot < UnaryOperator
      def node_class
        Keisan::AST::UnaryBitwiseNot
      end
    end
  end
end

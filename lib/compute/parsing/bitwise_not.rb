module Compute
  module Parsing
    class BitwiseNot < UnaryOperator
      def node_class
        Compute::AST::UnaryBitwiseNot
      end
    end
  end
end

module Compute
  module Parsing
    class BitwiseOr < BitwiseOperator
      def node_class
        Compute::AST::BitwiseOr
      end
    end
  end
end

module Compute
  module Parsing
    class BitwiseXor < BitwiseOperator
      def node_class
        Compute::AST::BitwiseXor
      end
    end
  end
end

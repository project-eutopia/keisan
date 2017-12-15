module Keisan
  module Parsing
    class BitwiseXor < BitwiseOperator
      def node_class
        AST::BitwiseXor
      end
    end
  end
end

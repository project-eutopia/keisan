module Keisan
  module Parsing
    class BitwiseXor < BitwiseOperator
      def node_class
        Keisan::AST::BitwiseXor
      end
    end
  end
end

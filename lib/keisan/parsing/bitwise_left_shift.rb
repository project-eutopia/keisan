module Keisan
  module Parsing
    class BitwiseLeftShift < BitwiseOperator
      def node_class
        AST::BitwiseLeftShift
      end
    end
  end
end

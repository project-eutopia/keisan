module Keisan
  module Parsing
    class BitwiseRightShift < BitwiseOperator
      def node_class
        AST::BitwiseRightShift
      end
    end
  end
end

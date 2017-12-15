module Keisan
  module Parsing
    class BitwiseOr < BitwiseOperator
      def node_class
        AST::BitwiseOr
      end
    end
  end
end

module Keisan
  module Parsing
    class BitwiseAnd < BitwiseOperator
      def node_class
        AST::BitwiseAnd
      end
    end
  end
end

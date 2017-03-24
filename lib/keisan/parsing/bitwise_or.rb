module Keisan
  module Parsing
    class BitwiseOr < BitwiseOperator
      def node_class
        Keisan::AST::BitwiseOr
      end
    end
  end
end

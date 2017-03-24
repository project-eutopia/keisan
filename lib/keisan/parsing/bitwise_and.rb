module Keisan
  module Parsing
    class BitwiseAnd < BitwiseOperator
      def node_class
        Keisan::AST::BitwiseAnd
      end
    end
  end
end

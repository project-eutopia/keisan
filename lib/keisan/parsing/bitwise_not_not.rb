module Keisan
  module Parsing
    class BitwiseNotNot < UnaryOperator
      def node_class
        Keisan::AST::UnaryIdentity
      end
    end
  end
end

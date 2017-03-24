module Keisan
  module Parsing
    class LogicalNotNot < UnaryOperator
      def node_class
        Keisan::AST::UnaryIdentity
      end
    end
  end
end

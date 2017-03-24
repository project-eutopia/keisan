module Compute
  module Parsing
    class BitwiseAnd < BitwiseOperator
      def node_class
        Compute::AST::BitwiseAnd
      end
    end
  end
end

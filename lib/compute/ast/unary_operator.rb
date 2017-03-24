module Compute
  module AST
    class UnaryOperator < Parent
      def initialize(children = [])
        children = Array.wrap(children)
        super
        if children.count != 1
          raise Compute::Exceptions::ASTError.new("Unary operator takes has a single child")
        end
      end
    end
  end
end

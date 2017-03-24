module Compute
  module AST
    class Node
      def value(context = nil)
        raise Compute::Exceptions::NotImplementedError.new
      end
    end
  end
end

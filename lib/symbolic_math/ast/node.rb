module SymbolicMath
  module AST
    class Node
      def value(context = nil)
        raise SymbolicMath::Exceptions::NotImplementedError.new
      end
    end
  end
end

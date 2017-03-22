module SymbolicMath
  module Parsing
    class Operator < Component
      def priority
        raise SymbolicMath::Exceptions::NotImplementedError.new
      end

      def node_class
        raise SymbolicMath::Exceptions::NotImplementedError.new
      end
    end
  end
end

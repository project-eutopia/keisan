module SymbolicMath
  module Parsing
    class Operator < Component
      def priority
        node_class.priority
      end

      def node_class
        raise SymbolicMath::Exceptions::NotImplementedError.new
      end
    end
  end
end

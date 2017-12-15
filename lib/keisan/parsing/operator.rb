module Keisan
  module Parsing
    class Operator < Component
      def arity
        node_class.arity
      end

      def priority
        node_class.priority
      end

      def associativity
        node_class.associativity
      end

      def node_class
        raise Exceptions::NotImplementedError.new
      end
    end
  end
end

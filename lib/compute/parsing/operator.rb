module Compute
  module Parsing
    class Operator < Component
      def priority
        node_class.priority
      end

      def node_class
        raise Compute::Exceptions::NotImplementedError.new
      end
    end
  end
end

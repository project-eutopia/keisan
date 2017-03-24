module Compute
  module Parsing
    class UnaryOperator < Component
      def node_class
        raise Compute::Exponent::NotImplementedError.new
      end
    end
  end
end

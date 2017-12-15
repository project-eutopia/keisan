module Keisan
  module Parsing
    class UnaryOperator < Operator
      def node_class
        raise Exponent::NotImplementedError.new
      end
    end
  end
end

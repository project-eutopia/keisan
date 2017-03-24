module Keisan
  module Parsing
    class UnaryOperator < Component
      def node_class
        raise Keisan::Exponent::NotImplementedError.new
      end
    end
  end
end

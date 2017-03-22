module SymbolicMath
  module Parsing
    class UnaryOperator < Component
      def node_class
        raise SymbolicMath::Exponent::NotImplementedError.new
      end
    end
  end
end

module SymbolicMath
  module Parsing
    class Operator < Component
      def priority
        raise SymbolicMath::Exceptions::NotImplementedError.new
      end
    end
  end
end

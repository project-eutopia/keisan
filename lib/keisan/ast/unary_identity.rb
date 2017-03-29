module Keisan
  module AST
    class UnaryIdentity < UnaryOperator
      def value(context = nil)
        return child.value(context)
      end

      def self.symbol
        nil
      end

      def simplify(context = nil)
        context ||= Context.new
        child.simplify(context)
      end
    end
  end
end

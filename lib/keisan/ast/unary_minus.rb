module Keisan
  module AST
    class UnaryMinus < UnaryOperator
      def value(context = nil)
        return -1 * child.value(context)
      end

      def to_s
        "-#{child.to_s}"
      end
    end
  end
end

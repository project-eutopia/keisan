module Keisan
  module AST
    class ConstantLiteral < Literal
      def evaluate(context = nil)
        self
      end

      def to_s
        value.to_s
      end
    end
  end
end

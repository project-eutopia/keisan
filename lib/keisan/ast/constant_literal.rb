module Keisan
  module AST
    class ConstantLiteral < Literal
      def to_s
        value.to_s
      end
    end
  end
end

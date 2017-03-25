module Keisan
  module AST
    class Literal < Node
      def ==(other)
        value == other.value
      end
    end
  end
end

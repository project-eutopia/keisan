module Keisan
  module AST
    class Literal < Node
      def ==(other)
        case other
        when Literal
          value == other.value
        else
          false
        end
      end
    end
  end
end

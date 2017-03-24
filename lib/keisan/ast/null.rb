module Keisan
  module AST
    class Null < Literal
      def initialize
      end

      def value(context = nil)
        nil
      end
    end
  end
end

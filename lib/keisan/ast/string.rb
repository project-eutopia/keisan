module Keisan
  module AST
    class String < ConstantLiteral
      attr_reader :content

      def initialize(content)
        @content = content
      end

      def value(context = nil)
        content
      end
    end
  end
end

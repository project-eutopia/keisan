module Keisan
  module AST
    class String < Literal
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

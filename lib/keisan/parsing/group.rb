module Keisan
  module Parsing
    class Group < Element
      attr_reader :components

      def initialize(sub_tokens)
        @components = Parser.new(tokens: sub_tokens).components
      end
    end
  end
end

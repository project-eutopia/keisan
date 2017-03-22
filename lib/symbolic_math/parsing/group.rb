module SymbolicMath
  module Parsing
    class Group < Element
      attr_reader :components

      def initialize(sub_tokens)
        @components = SymbolicMath::Parser.new(tokens: sub_tokens).components
      end
    end
  end
end

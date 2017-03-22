module SymbolicMath
  module Tokens
    class Group < Token
      REGEX = /(\(.*\))/

      attr_reader :sub_tokens

      def initialize(string)
        super
        @sub_tokens = Tokenizer.new(string[1...-1]).tokens
      end

      def self.regex
        REGEX
      end
    end
  end
end

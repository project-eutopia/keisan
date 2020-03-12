module Keisan
  module Tokens
    class Group < Token
      REGEX = /(\(|\)|\[|\]|\{|\})/

      attr_reader :sub_tokens

      def initialize(string)
        @string = string
        raise Exceptions::InvalidToken.new(string) unless string[0].match(regex) && string[-1].match(regex)
        @sub_tokens = Tokenizer.new(string[1...-1]).tokens
      end

      def self.regex
        REGEX
      end

      # Either :round, :square
      def group_type
        case string[0]
        when "("
          :round
        when "["
          :square
        when "{"
          :curly
        end
      end
    end
  end
end

module Keisan
  module Tokens
    class Group < Token
      REGEX = /(\((?:[^\[\]\(\)]*\g<1>*)*\)|\[(?:[^\[\]\(\)]*\g<1>*)*\])/

      attr_reader :sub_tokens

      def initialize(string)
        super
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
        end
      end
    end
  end
end

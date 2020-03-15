module Keisan
  module Tokens
    class Group < Token
      attr_reader :sub_tokens

      def initialize(string)
        @string = string
        @sub_tokens = Tokenizer.new(string[1...-1]).tokens
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

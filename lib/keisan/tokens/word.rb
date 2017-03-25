module Keisan
  module Tokens
    class Word < Token
      REGEX = /([a-zA-Z_]\w*)/

      def self.regex
        REGEX
      end
    end
  end
end

module Compute
  module Tokens
    class Word < Token
      REGEX = /([a-zA-Z0-9_]*[a-zA-Z][a-zA-Z0-9_]*)/

      def self.regex
        REGEX
      end
    end
  end
end

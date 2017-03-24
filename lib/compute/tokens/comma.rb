module Compute
  module Tokens
    class Comma < Token
      REGEX = /(\,)/

      def self.regex
        REGEX
      end
    end
  end
end

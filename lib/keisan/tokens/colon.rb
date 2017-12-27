module Keisan
  module Tokens
    class Colon < Token
      REGEX = /(\:)/

      def self.regex
        REGEX
      end
    end
  end
end

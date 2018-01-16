module Keisan
  module Tokens
    class Unknown < Token
      REGEX = /([^[[:space:]]]+?)/

      def self.regex
        REGEX
      end
    end
  end
end

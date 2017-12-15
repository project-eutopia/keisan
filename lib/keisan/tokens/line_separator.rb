module Keisan
  module Tokens
    class LineSeparator < Token
      REGEX = /([;\n]+)/

      def self.regex
        REGEX
      end
    end
  end
end

module Keisan
  module Tokens
    class Dot < Token
      REGEX = /(\.)/

      def self.regex
        REGEX
      end
    end
  end
end

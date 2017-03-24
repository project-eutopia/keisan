module Compute
  module Tokens
    class Null < Token
      REGEX = /(\bnil\b)/

      def self.regex
        REGEX
      end

      def value
        nil
      end
    end
  end
end

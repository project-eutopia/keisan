module Keisan
  module Tokens
    class Boolean < Token
      REGEX = /((?:\btrue\b)|(?:\bfalse\b))/

      def self.regex
        REGEX
      end

      def value
        case string
        when "true"
          true
        else
          false
        end
      end
    end
  end
end

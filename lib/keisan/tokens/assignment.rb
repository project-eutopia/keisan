module Keisan
  module Tokens
    class Assignment < Operator
      REGEX = /(\=)/

      def self.regex
        REGEX
      end
    end
  end
end

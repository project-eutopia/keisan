module Keisan
  module Tokens
    class Assignment < Operator
      REGEX = /(\=)/

      def self.regex
        REGEX
      end

      def operator_type
        :"="
      end
    end
  end
end

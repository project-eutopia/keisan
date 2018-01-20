module Keisan
  module Tokens
    class Assignment < Operator
      # Optional arithmetic/bitwise operators in front of equals
      # Negative lookahead at end to prevent collision with "=="
      # TODO: Handle ||= and &&= operators?
      REGEX = /((?:\*\*|\+|\-|\*|\/)?\=(?!\=))/

      def self.regex
        REGEX
      end

      def operator_type
        :"="
      end

      def compound_operator
        string[0] == "=" ? nil : string[0].to_sym
      end
    end
  end
end

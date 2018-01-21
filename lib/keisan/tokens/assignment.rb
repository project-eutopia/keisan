module Keisan
  module Tokens
    class Assignment < Operator
      REGEX = /(
        (?: # possible compound operators in front of equals
         \|\| |
         \&\& |
         \*\* |
         \+ |
         \- |
         \* |
         \/ |
         \% |
         \& |
         \| |
         \^
        )?
        \=
        (?!\=) # negative lookahead to prevent matching ==
      )/x

      def self.regex
        REGEX
      end

      def operator_type
        :"="
      end

      def compound_operator
        string[0] == "=" ? nil : string[0...-1].to_sym
      end
    end
  end
end

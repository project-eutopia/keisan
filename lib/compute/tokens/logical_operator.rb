module Compute
  module Tokens
    class LogicalOperator < Operator
      LESS_THAN_OR_EQUAL_TO = /(?:\<\=)/
      GREATER_THAN_OR_EQUAL_TO = /(?:\>\=)/
      LESS_THAN = /(?:\<)/
      GREATER_THAN = /(?:\>)/
      AND = /(?:\&\&)/
      OR = /(?:\|\|)/
      NOT = /(?:\!+)/

      REGEX = /(#{LESS_THAN_OR_EQUAL_TO}|#{GREATER_THAN_OR_EQUAL_TO}|#{LESS_THAN}|#{GREATER_THAN}|#{AND}|#{OR}|#{NOT})/

      def self.regex
        REGEX
      end

      def operator_type
        case string
        when LESS_THAN_OR_EQUAL_TO
          :<=
        when GREATER_THAN_OR_EQUAL_TO
          :>=
        when LESS_THAN
          :<
        when GREATER_THAN
          :>
        when AND
          :"&&"
        when OR
          :"||"
        when NOT
          string.count("!").even? ? :"!!" : :"!"
        end
      end
    end
  end
end

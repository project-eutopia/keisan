module SymbolicMath
  module Tokens
    class Operator < Token
      PLUS_OR_MINUS = /(?:[\+\-]+)/
      TIMES = /(?:\*)/
      DIVIDE = /(?:\/)/
      EXPONENT = /(?:\*\*)/
      REGEX = /(#{EXPONENT}|#{PLUS_OR_MINUS}|#{TIMES}|#{DIVIDE})/

      def self.regex
        REGEX
      end

      def operator_type
        case string
        when EXPONENT
          # Must match first to override matching against single "*"
          :^
        when TIMES
          :*
        when DIVIDE
          :/
        when PLUS_OR_MINUS
          string.count("-").even? ? :+ : :-
        end
      end
    end
  end
end

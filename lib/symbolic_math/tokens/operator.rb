module SymbolicMath
  module Tokens
    class Operator < Token
      PLUS = /(?:\+\+|\-\-|\+)/
      MINUS = /(?:\+\-|\-\+|\-)/
      TIMES = /(?:\*)/
      DIVIDE = /(?:\/)/
      EXPONENT = /(?:\*\*)/
      REGEX = /(#{EXPONENT}|#{PLUS}|#{MINUS}|#{TIMES}|#{DIVIDE})/

      def self.regex
        REGEX
      end
    end
  end
end

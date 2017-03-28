module Keisan
  module AST
    class Priorities
      PRIORITIES = {
        "u!": 100,
        "u~": 100,
        "u+": 100,
        "**": 95,
        "u-": 90,
        "*": 85,
        "/": 85,
        "%": 85,
        "+": 80,
        "-": 80,
        "&": 70,
        "^": 65,
        "|": 65,
        ">": 60,
        ">=": 60,
        "<": 60,
        "<=": 60,
        "==": 55,
        "!=": 55,
        "&&": 50,
        "||": 45,
        "=": 40
      }.freeze

      def self.priorities
        PRIORITIES
      end
    end
  end
end

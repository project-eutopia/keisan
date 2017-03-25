module Keisan
  module AST
    class Priorities
      PRIORITIES = {
        "**": 100,
        "*": 95,
        "%": 90,
        "+": 85,
        "&": 80,
        "^": 75,
        "|": 70,
        ">": 65,
        ">=": 60,
        "<": 55,
        "<=": 50,
        "==": 45,
        "!=": 40,
        "&&": 35,
        "||": 30
      }.freeze

      def self.priorities
        PRIORITIES
      end
    end
  end
end

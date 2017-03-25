module Keisan
  module AST
    def self.parse(expression)
      AST::Builder.new(string: expression).ast
    end
  end
end

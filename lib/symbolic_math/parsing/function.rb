module SymbolicMath
  module Parsing
    class Function < Element
      attr_reader :name, :arguments

      def initialize(name, arguments)
        @name = name
        @arguments = arguments
        # TODO
        # binding.pry
      end
    end
  end
end

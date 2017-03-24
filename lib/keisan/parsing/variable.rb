module Keisan
  module Parsing
    class Variable < Element
      attr_reader :name

      def initialize(name)
        @name = name
      end
    end
  end
end

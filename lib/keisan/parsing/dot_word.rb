module Keisan
  module Parsing
    class DotWord < Component
      attr_reader :name
      def initialize(name)
        @name = name
      end

      def arguments
        []
      end
    end
  end
end

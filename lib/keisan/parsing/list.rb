module Keisan
  module Parsing
    class List < SquareGroup
      attr_reader :arguments
      def initialize(arguments)
        @arguments = arguments
      end
    end
  end
end

module Compute
  module Parsing
    class Boolean < Element
      attr_reader :value

      def initialize(value)
        @value = value
      end
    end
  end
end

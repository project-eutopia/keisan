module Keisan
  module Parsing
    class DotOperator < Element
      attr_reader :name, :arguments

      def initialize(name, arguments)
        @name = name
        @arguments = arguments
      end
    end
  end
end

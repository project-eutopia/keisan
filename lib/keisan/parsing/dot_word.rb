module Keisan
  module Parsing
    class DotWord < Component
      attr_reader :name, :target
      def initialize(name, target)
        @name = name
        @target = target
      end
    end
  end
end

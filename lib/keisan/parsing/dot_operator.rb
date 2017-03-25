module Keisan
  module Parsing
    class DotOperator < Element
      attr_reader :name, :target, :arguments

      # Given a.size(i):
      # name = "size"
      # target = a
      # arguments = [i]
      def initialize(name, target, arguments)
        @name = name
        @target = target
        @arguments = arguments
      end
    end
  end
end

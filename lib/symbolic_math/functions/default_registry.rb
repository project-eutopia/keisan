require_relative "sin"

module SymbolicMath
  module Functions
    class DefaultRegistry < Registry
      def initialize
        @hash = {}
        @parent = self.class.registry
      end

      FUNCTIONS = {
        "sin" => Sin.new
      }

      def self.registry
        @registry ||= Registry.new(FUNCTIONS, nil)
      end
    end
  end
end

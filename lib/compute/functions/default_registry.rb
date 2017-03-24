require_relative "sin"

module Compute
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
        @registry ||= Registry.new(functions: FUNCTIONS, parent: nil)
      end
    end
  end
end

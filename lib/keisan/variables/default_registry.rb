module Keisan
  module Variables
    class DefaultRegistry < Registry
      def initialize
        @hash = {}
        @parent = self.class.registry
      end

      VARIABLES = {
        "pi" => Math::PI,
        "e" => Math::E,
        "i" => Complex(0,1)
      }

      def self.registry
        @registry ||= Registry.new(variables: VARIABLES, parent: nil).freeze
      end
    end
  end
end

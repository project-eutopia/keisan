require_relative "sin"

module Compute
  module Functions
    class DefaultRegistry
      def self.registry
        @registry ||= Registry.new.tap do |r|
          register_defaults!(r)
        end.freeze
      end

      private

      def self.register_defaults!(registry)
        Math.methods(false).each do |method|
          registry.register!(
            method,
            Proc.new do |*args|
              Math.send(method, *args)
            end
          )
        end
      end
    end
  end
end

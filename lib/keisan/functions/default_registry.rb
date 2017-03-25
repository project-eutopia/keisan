require_relative "rand"
require_relative "sample"

module Keisan
  module Functions
    class DefaultRegistry
      def self.registry
        @registry ||= Registry.new.tap do |r|
          register_defaults!(r)
        end.freeze
      end

      private

      def self.register_defaults!(registry)
        register_builtin_math!(registry)
        register_array_methods!(registry)
        register_random_methods!(registry)
      end

      def self.register_builtin_math!(registry)
        Math.methods(false).each do |method|
          registry.register!(
            method,
            Proc.new do |*args|
              Math.send(method, *args)
            end
          )
        end
      end

      def self.register_array_methods!(registry)
        %i(min max size).each do |method|
          registry.register!(method, Proc.new {|a| a.send(method)})
        end
      end

      def self.register_random_methods!(registry)
        registry.register!(:rand, Keisan::Functions::Rand.new)
        registry.register!(:sample, Keisan::Functions::Sample.new)
      end
    end
  end
end

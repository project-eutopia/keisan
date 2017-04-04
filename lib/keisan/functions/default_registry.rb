require_relative "if"
require_relative "diff"
require_relative "replace"
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
        registry.register!(:if, Keisan::Functions::If.new, force: true)
        registry.register!(:diff, Keisan::Functions::Diff.new, force: true)
        registry.register!(:replace, Keisan::Functions::Replace.new, force: true)

        register_builtin_math!(registry)
        register_array_methods!(registry)
        register_random_methods!(registry)
      end

      def self.register_builtin_math!(registry)
        Math.methods(false).each do |method|
          registry.register!(
            method,
            Proc.new {|*args|
              Math.send(method, *args)
            },
            force: true
          )
        end
      end

      def self.register_array_methods!(registry)
        %i(min max size).each do |method|
          registry.register!(method, Proc.new {|a| a.send(method)}, force: true)
        end
      end

      def self.register_random_methods!(registry)
        registry.register!(:rand, Keisan::Functions::Rand.new, force: true)
        registry.register!(:sample, Keisan::Functions::Sample.new, force: true)
      end
    end
  end
end

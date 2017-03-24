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
        register_builtin_math!(registry)
        register_branch_methods!(registry)
        register_array_methods!(registry)
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

      def self.register_branch_methods!(registry)
        registry.register!(:if, Proc.new {|bool, a, b=nil| bool ? a : b })
      end

      def self.register_array_methods!(registry)
        %i(min max size).each do |method|
          registry.register!(method, Proc.new {|a| a.send(method)})
        end
      end
    end
  end
end

module Keisan
  module Variables
    class Registry
      def initialize(variables: {}, parent: nil, use_defaults: true)
        @hash = {}
        @parent = parent
        @use_defaults = use_defaults

        variables.each do |name, value|
          register!(name, value)
        end
      end

      def [](name)
        return @hash[name] if @hash.has_key?(name)
        return @parent[name] if @parent.present? && @parent.has_name?(name)
        return default_registry[name] if @use_defaults && default_registry.has_name?(name)
        raise Keisan::Exceptions::UndefinedVariableError.new name
      end

      def has_name?(name)
        @hash.has_key?(name)
      end

      def register!(name, value)
        raise Keisan::Exceptions::UnmodifiableError.new("Cannot modify frozen variables registry") if frozen?
        self[name.to_s] = value
      end

      private

      def []=(name, value)
        @hash[name] = value
      end

      def default_registry
        DefaultRegistry.registry
      end
    end
  end
end
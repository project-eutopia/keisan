module Keisan
  module Variables
    class Registry
      def initialize(variables: {}, shadowed: [], parent: nil, use_defaults: true, force: false)
        @hash = {}
        @shadowed = Set.new(shadowed)
        @parent = parent
        @use_defaults = use_defaults

        variables.each do |name, value|
          register!(name, value, force: force)
        end
      end

      def [](name)
        raise Keisan::Exceptions::UndefinedVariableError.new if @shadowed.include?(name)
        return @hash[name] if @hash.has_key?(name)

        if @parent && (parent_value = @parent[name])
          return parent_value
        end

        return default_registry[name] if @use_defaults && default_registry.has_name?(name)
        raise Keisan::Exceptions::UndefinedVariableError.new name
      end

      def locals
        @hash
      end

      def has?(name)
        return false if @shadowed.include?(name)
        !self[name].nil?
      rescue Keisan::Exceptions::UndefinedVariableError
        false
      end

      def register!(name, value, force: false)
        return if @shadowed.include?(name)
        raise Keisan::Exceptions::UnmodifiableError.new("Cannot modify frozen variables registry") if frozen?
        if !force && @use_defaults && default_registry.has_name?(name)
          raise Keisan::Exceptions::UnmodifiableError.new("Cannot overwrite default variable")
        end
        self[name.to_s] = value.to_node
      end

      protected

      # For checking if locally defined
      def has_name?(name)
        @hash.has_key?(name)
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

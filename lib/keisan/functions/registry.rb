module Keisan
  module Functions
    class Registry
      def initialize(functions: {}, parent: nil, use_defaults: true, force: false)
        @hash = {}
        @parent = parent
        @use_defaults = use_defaults

        functions.each do |name, function|
          register!(name, function, force: force)
        end
      end

      def [](name)
        return @hash[name] if @hash.has_key?(name)

        if @parent && (parent_value = @parent[name])
          return parent_value
        end

        return default_registry[name] if @use_defaults && default_registry.has_name?(name)
        raise Exceptions::UndefinedFunctionError.new name
      end

      def locals
        @hash
      end

      def has?(name)
        !!self[name]
      rescue Exceptions::UndefinedFunctionError
        false
      end

      def modifiable?(name)
        !frozen? && has?(name)
      end

      def register!(name, function, force: false)
        raise Exceptions::UnmodifiableError.new("Cannot modify frozen functions registry") if frozen?
        name = name.to_s

        case function
        when Proc
          self[name] = ProcFunction.new(name, function)
        when Function
          self[name] = function
        else
          raise Exceptions::InvalidFunctionError.new
        end
      end

      protected

      # For checking if locally defined
      def has_name?(name)
        @hash.has_key?(name)
      end

      private

      def []=(name, function)
        @hash[name] = function
      end

      def default_registry
        DefaultRegistry.registry
      end
    end
  end
end

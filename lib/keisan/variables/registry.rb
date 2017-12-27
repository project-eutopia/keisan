module Keisan
  module Variables
    class Registry
      attr_reader :shadowed

      def initialize(variables: {}, shadowed: [], parent: nil, use_defaults: true, force: false)
        @hash = {}
        @shadowed = Set.new(shadowed.map(&:to_s))
        @parent = parent
        @use_defaults = use_defaults

        variables.each do |name, value|
          register!(name, value, force: force)
        end
      end

      def [](name)
        return @hash[name] if @hash.has_key?(name)
        raise Exceptions::UndefinedVariableError.new if @shadowed.include?(name)

        if @parent && (parent_value = @parent[name])
          return parent_value
        end

        return default_registry[name] if @use_defaults && default_registry.has_name?(name)
        raise Exceptions::UndefinedVariableError.new name
      end

      def locals
        @hash
      end

      def has?(name)
        !self[name].nil?
      rescue Exceptions::UndefinedVariableError
        false
      end

      def modifiable?(name)
        !frozen? && has?(name)
      end

      def register!(name, value, force: false)
        name = name.to_s
        name = name.name if name.is_a?(AST::Variable)

        raise Exceptions::UnmodifiableError.new("Cannot modify frozen variables registry") if frozen?
        self[name.to_s] = AST::Cell.new(value.to_node)
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

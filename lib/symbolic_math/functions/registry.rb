module SymbolicMath
  module Functions
    class Registry
      def initialize(functions = {}, parent = nil, use_defaults = true)
        @hash = {}
        @parent = parent
        @use_defaults = use_defaults

        functions.each do |name, function|
          register!(name, function)
        end
      end

      def [](name)
        return @hash[name] if @hash.has_key?(name)
        return @parent[name] if @parent.present? && @parent.has_name?(name)
        return default_registry[name] if @use_defaults && default_registry.has_name?(name)
        raise SymbolicMath::Exceptions::InvalidFunctionError.new "Undefined function #{name}"
      end

      def has_name?(name)
        @hash.has_key?(name)
      end

      def register!(name, function)
        case function
        when Proc
          self[name] = SymbolicMath::Function.new(name, function)
        when SymbolicMath::Function
          self[function.name] = function
        else
          raise SymbolicMath::Exceptions::InvalidFunctionError.new
        end
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

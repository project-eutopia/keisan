module SymbolicMath
  class Context
    def initialize(function_registry: nil, variable_registry: nil)
      @function_registry = function_registry || Functions::Registry.new
      @variable_registry = variable_registry || Variables::Registry.new
    end

    def function(name)
      @function_registry[name.to_s]
    end

    def register_function!(name, function)
      @function_registry.register!(name.to_s, function)
    end

    def variable(name)
      @variable_registry[name.to_s]
    end

    def register_variable!(name, value)
      @variable_registry.register!(name.to_s, value)
    end
  end
end

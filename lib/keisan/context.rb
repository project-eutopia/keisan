module Keisan
  class Context
    attr_reader :function_registry, :variable_registry

    def initialize(parent: nil, random: nil)
      @parent = parent
      @function_registry = Functions::Registry.new(parent: @parent.try(:function_registry))
      @variable_registry = Variables::Registry.new(parent: @parent.try(:variable_registry))
      @random            = random
    end

    def spawn_child(definitions = {})
      child = self.class.new(parent: self)

      definitions.each do |name, value|
        case value
        when Proc
          child.register_function!(name, value)
        else
          child.register_variable!(name, value)
        end
      end

      child
    end

    def function(name)
      @function_registry[name.to_s]
    end

    def has_function?(name)
      @function_registry.has?(name)
    end

    def register_function!(name, function)
      @function_registry.register!(name.to_s, function)
    end

    def variable(name)
      @variable_registry[name.to_s]
    end

    def has_variable?(name)
      @variable_registry.has?(name)
    end

    def register_variable!(name, value)
      @variable_registry.register!(name.to_s, value)
    end

    def random
      @random || @parent.try(:random) || Random.new
    end
  end
end

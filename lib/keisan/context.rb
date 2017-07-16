module Keisan
  class Context
    attr_reader :function_registry, :variable_registry, :allow_recursive

    def initialize(parent: nil, random: nil, allow_recursive: false)
      @parent = parent
      @function_registry = Functions::Registry.new(parent: @parent.try(:function_registry))
      @variable_registry = Variables::Registry.new(parent: @parent.try(:variable_registry))
      @random            = random
      @allow_recursive   = allow_recursive
    end

    def spawn_child(definitions: {}, transient: false)
      child = self.class.new(parent: self, allow_recursive: allow_recursive)

      definitions.each do |name, value|
        case value
        when Proc
          child.register_function!(name, value)
        else
          child.register_variable!(name, value)
        end
      end

      child.set_transient! if transient
      child
    end

    def variable(name)
      @variable_registry[name.to_s]
    end

    def has_variable?(name)
      @variable_registry.has?(name)
    end

    def register_variable!(name, value)
      if @transient
        @parent.register_variable!(name, value)
      else
        @variable_registry.register!(name.to_s, value)
      end
    end

    def function(name)
      @function_registry[name.to_s]
    end

    def has_function?(name)
      @function_registry.has?(name)
    end

    def register_function!(name, function)
      if @transient
        @parent.register_function!(name, function)
      else
        @function_registry.register!(name.to_s, function)
      end
    end

    def random
      @random || @parent.try(:random) || Random.new
    end

    protected

    def set_transient!
      @transient = true
    end
  end
end

module Keisan
  class Context
    attr_reader :function_registry,
      :variable_registry,
      :allow_recursive,
      :allow_multiline,
      :allow_blocks

    def initialize(parent: nil,
                   random: nil,
                   allow_recursive: false,
                   allow_multiline: true,
                   allow_blocks: true,
                   shadowed: [])
      @parent = parent
      @function_registry = Functions::Registry.new(parent: @parent&.function_registry)
      @variable_registry = Variables::Registry.new(parent: @parent&.variable_registry, shadowed: shadowed)
      @random            = random
      @allow_recursive   = allow_recursive
      @allow_multiline   = allow_multiline
      @allow_blocks      = allow_blocks
    end

    def allow_recursive!
      @allow_recursive = true
    end

    def freeze
      super
      @function_registry.freeze
      @variable_registry.freeze
    end

    # A transient context does not persist variables and functions in this context, but
    # rather store them one level higher in the parent context.  When evaluating a string,
    # the entire operation is done in a transient context that is unique from the calculators
    # current context, but such that variable/function definitions can be persisted in
    # the calculator.
    def spawn_child(definitions: {}, shadowed: [], transient: nil)
      child = pure_child(shadowed: shadowed)

      definitions.each do |name, value|
        case value
        when Proc
          child.register_function!(name, value)
        when Functions::ProcFunction
          child.register_function!(name, value.function_proc)
        else
          child.register_variable!(name, value)
        end
      end

      if transient.nil? && self.transient? || transient == true
        child.set_transient!
      end
      child
    end

    def transient_definitions
      return {} unless @transient
      parent_definitions = @parent.nil? ? {} : @parent.transient_definitions
      parent_definitions.merge(
        @variable_registry.locals
      ).merge(
        @function_registry.locals
      )
    end

    def transient?
      !!@transient
    end

    def variable(name)
      @variable_registry[name.to_s]
    end

    def has_variable?(name)
      @variable_registry.has?(name)
    end

    def variable_is_modifiable?(name)
      @variable_registry.modifiable?(name)
    end

    def register_variable!(name, value, local: false)
      if !@variable_registry.shadowed.member?(name) && (transient? || !local && @parent&.variable_is_modifiable?(name))
        @parent.register_variable!(name, value, local: local)
      else
        @variable_registry.register!(name, value)
      end
    end

    def function(name)
      @function_registry[name.to_s]
    end

    def has_function?(name)
      @function_registry.has?(name)
    end

    def function_is_modifiable?(name)
      @function_registry.modifiable?(name)
    end

    def register_function!(name, function, local: false)
      if transient? || !local && @parent&.function_is_modifiable?(name)
        @parent.register_function!(name, function, local: local)
      else
        @function_registry.register!(name.to_s, function)
      end
    end

    def random
      @random || @parent&.random || Random.new
    end

    protected

    def set_transient!
      @transient = true
    end

    def pure_child(shadowed: [])
      self.class.new(
        parent: self,
        shadowed: shadowed,
        allow_recursive: allow_recursive,
        allow_multiline: allow_multiline,
        allow_blocks: allow_blocks
      )
    end
  end
end

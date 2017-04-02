module Keisan
  class FunctionDefinitionContext < Context
    def initialize(parent:, arguments:)
      super(parent: parent)
      @arguments = Set.new(arguments)
      @arguments_context = Context.new
      set_transient!
    end

    def variable(name)
      if @arguments.member?(name)
        @arguments_context.variable(name)
      else
        super
      end
    end

    def has_variable?(name)
      if @arguments.member?(name)
        @arguments_context.has_variable?(name)
      else
        super
      end
    end

    def register_variable!(name, value)
      if @arguments.member?(name)
        @arguments_context.register_variable!(name, value)
      else
        super
      end
    end
  end
end

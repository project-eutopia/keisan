module Keisan
  class FunctionDefinitionContext < Context
    def initialize(parent:, arguments:, allow_recursive: false, arguments_context: nil)
      super(parent: parent, allow_recursive: allow_recursive)
      @arguments = Set.new(arguments)
      @arguments_context = arguments_context || Context.new
      set_transient!
    end

    def variable(name)
      @arguments.member?(name) ? @arguments_context.variable(name) : super
    end

    def has_variable?(name)
      @arguments.member?(name) ? @arguments_context.has_variable?(name) : super
    end

    def register_variable!(name, value)
      @arguments.member?(name) ? @arguments_context.register_variable!(name, value) : super
    end

    protected

    def pure_child
      self.class.new(parent: self, arguments: @arguments, arguments_context: @arguments_context, allow_recursive: allow_recursive)
    end
  end
end

module Keisan
  class FunctionDefinitionContext < Context
    def initialize(parent:, arguments:, shadowed: [], allow_recursive: false, arguments_context: nil)
      super(parent: parent, shadowed: shadowed, allow_recursive: allow_recursive)
      @arguments = Set.new(arguments.map(&:to_s))
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

    def pure_child(shadowed: [])
      self.class.new(parent: self, shadowed: shadowed, arguments: @arguments, arguments_context: @arguments_context, allow_recursive: allow_recursive)
    end
  end
end

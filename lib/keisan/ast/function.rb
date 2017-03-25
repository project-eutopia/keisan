module Keisan
  module AST
    class Function < Parent
      attr_reader :name

      def initialize(arguments = [], name)
        @name = name
        super(arguments)
      end

      def value(context = nil)
        context = Keisan::Context.new if context.nil?
        argument_values = children.map {|child| child.value(context)}
        function = context.function(name)
        function.call(context, *argument_values)
      end

      def unbound_functions(context = nil)
        context ||= Keisan::Context.new
        functions = children.inject(Set.new) do |res, child|
          res | child.unbound_functions(context)
        end
        if context.has_function?(name)
          functions
        else
          functions | Set.new([name])
        end
      end
    end
  end
end

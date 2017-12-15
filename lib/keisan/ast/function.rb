module Keisan
  module AST
    class Function < Parent
      attr_reader :name

      def initialize(arguments = [], name)
        @name = name
        super(arguments)
      end

      def value(context = nil)
        context ||= Context.new
        function_from_context(context).value(self, context)
      end

      def unbound_functions(context = nil)
        context ||= Context.new

        functions = children.inject(Set.new) do |res, child|
          res | child.unbound_functions(context)
        end

        context.has_function?(name) ? functions : functions | Set.new([name])
      end

      def function_defined?(context = nil)
        context ||= Context.new
        context.has_function?(name)
      end

      def function_from_context(context)
        context.function(name)
      end

      def ==(other)
        case other
        when Function
          name == other.name && super
        else
          false
        end
      end

      def evaluate(context = nil)
        context ||= Context.new

        if function_defined?(context)
          function_from_context(context).evaluate(self, context)
        else
          @children = children.map {|child| child.evaluate(context).to_node}
          self
        end
      end

      def simplify(context = nil)
        context ||= Context.new

        if function_defined?(context)
          function_from_context(context).simplify(self, context)
        else
          @children = children.map {|child| child.simplify(context).to_node}
          self
        end
      end

      def to_s
        "#{name}(#{children.map(&:to_s).join(',')})"
      end

      def differentiate(variable, context = nil)
        function = function_from_context(context)
        function.differentiate(self, variable, context)

      rescue Exceptions::UndefinedFunctionError, Exceptions::NotImplementedError
        unless unbound_variables(context).include?(variable.name)
          return Number.new(0)
        end

        self.class.new([self, variable], "diff")
      end
    end
  end
end

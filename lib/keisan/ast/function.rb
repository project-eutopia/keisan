module Keisan
  module AST
    class Function < Parent
      attr_reader :name

      def initialize(arguments = [], name)
        @name = name
        super(arguments)
      end

      def value(context = nil)
        context ||= Keisan::Context.new
        function_from_context(context).value(self, context)
      end

      def unbound_functions(context = nil)
        context ||= Keisan::Context.new

        functions = children.inject(Set.new) do |res, child|
          res | child.unbound_functions(context)
        end

        context.has_function?(name) ? functions : functions | Set.new([name])
      end

      def function_defined?(context = nil)
        context ||= Keisan::Context.new
        context.has_function?(name)
      end

      def function_from_context(context)
        context.function(name)
      end

      def ==(other)
        case other
        when AST::Function
          name == other.name && super
        else
          false
        end
      end

      def evaluate(context = nil)
        context ||= Keisan::Context.new

        if function_defined?(context)
          function_from_context(context).evaluate(self, context)
        else
          @children = children.map {|child| child.evaluate(context)}
          self
        end
      end

      def simplify(context = nil)
        context ||= Context.new

        if function_defined?(context)
          function_from_context(context).simplify(self, context)
        else
          @children = children.map {|child| child.simplify(context)}
          self
        end
      end

      def to_s
        "#{name}(#{children.map(&:to_s).join(',')})"
      end

      def differentiate(variable, context = nil)
        unless unbound_variables(context).include?(variable.name)
          return AST::Number.new(0)
        end
        # Do not know how to differentiate a function in general, so leave as derivative
        AST::Function.new([self, variable], "diff")
      end
    end
  end
end

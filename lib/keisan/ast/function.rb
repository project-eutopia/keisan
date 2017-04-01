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
        function = function_from_context(context)
        function.call(context, *argument_values)
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

        super

        if function_defined?(context) && children.all? {|child| child.is_a?(ConstantLiteral)}
          function = function_from_context(context)
          function.call(context, *children.map {|child| child.value(context)}).to_node.evaluate(context)
        else
          self
        end
      end

      def simplify(context = nil)
        context ||= Context.new

        super
        if function_defined?(context) && children.all? {|child| child.is_a?(ConstantLiteral)}
          value(context).to_node.simplify(context)
        else
          self
        end
      end

      def to_s
        "#{name}(#{children.map(&:to_s).join(',')})"
      end
    end

    class If < Function
      def value(context = nil)
        unless (2..3).cover? children.size
          raise Keisan::Exceptions::InvalidFunctionError.new("Require 2 or 3 arguments to if")
        end

        bool = children[0].value(context)

        if bool
          children[1].value(context)
        else
          children.size == 3 ? children[2].value(context) : nil
        end
      end

      def unbound_functions(context = nil)
        context ||= Keisan::Context.new

        children.inject(Set.new) do |res, child|
          res | child.unbound_functions(context)
        end
      end
    end

    class Function
      def self.build(name, arguments = [])
        case name.downcase
        when "if"
          If.new(arguments, name)
        else
          Function.new(arguments, name)
        end
      end
    end
  end
end

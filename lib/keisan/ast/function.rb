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

        if function_defined?(context) && children.all? {|child| child.well_defined?(context)}
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
  end
end

require_relative "functions/if"

module Keisan
  module AST
    class Function
      BUILD_CLASSES = {
        "if" => AST::Functions::If
      }.freeze

      def self.build(name, arguments = [])
        build_class(name.downcase).new(arguments, name)
      end

      def self.build_class(name)
        BUILD_CLASSES[name] || Function
      end
    end
  end
end

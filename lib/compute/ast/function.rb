module Compute
  module AST
    class Function < Parent
      attr_reader :name

      def initialize(arguments = [], name)
        @name = name
        super(arguments)
      end

      def value(context = nil)
        context = Compute::Context.new if context.nil?
        argument_values = children.map {|child| child.value(context)}
        function = context.function(name)
        function.call(*argument_values)
      end
    end
  end
end

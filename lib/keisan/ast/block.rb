module Keisan
  module AST
    class Block < Node
      attr_reader :child

      def initialize(child)
        @child = child
      end

      def unbound_variables(context = nil)
        local = get_local_context(context)
        child.unbound_variables(local)
      end

      def unbound_functions(context = nil)
        local = get_local_context(context)
        child.unbound_functions(local)
      end

      def traverse(&block)
        super(&block) || child.traverse(&block)
      end

      def deep_dup
        dupped = dup
        dupped.instance_variable_set(
          :@child,
          dupped.child.deep_dup
        )
        dupped
      end

      def value(context = nil)
        local = get_local_context(context)
        child.evaluated(local).value(local)
      end

      def evaluate(context = nil)
        local = get_local_context(context)
        child.evaluate(local)
      end

      def simplify(context = nil)
        local = get_local_context(context)
        child.simplify(local)
      end

      def replace(variable, replacement)
        self
      end

      def to_s
        "{#{child}}"
      end

      private

      def get_local_context(context)
        context ||= Context.new
        context.spawn_child(transient: false)
      end
    end
  end
end

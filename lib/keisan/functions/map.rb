require "keisan/functions/enumerable_function"

module Keisan
  module Functions
    class Map < EnumerableFunction
      # Maps
      # (list, variable, expression)
      # (hash, key, value, expression)
      def initialize
        super("map")
      end

      def unbound_variables(children, context)
        if children.size == 3
          super - Set[children[1].name]
        else
          super - Set[children[1].name, children[2].name]
        end
      end

      private

      def evaluate_list(list, arguments, expression, context)
        unless arguments.count == 1
          raise Exceptions::InvalidFunctionError.new("Map on list must take 3 arguments")
        end
        variable = arguments.first

        local = context.spawn_child(transient: false, shadowed: [variable.name])

        AST::List.new(
          list.children.map do |element|
            local.register_variable!(variable, element)
            expression.simplified(local)
          end
        )
      end

      def evaluate_hash(hash, arguments, expression, context)
        unless arguments.count == 2
          raise Exceptions::InvalidFunctionError.new("Map on hash must take 4 arguments")
        end
        key, value = arguments[0..1]

        local = context.spawn_child(transient: false, shadowed: [key.name, value.name])

        AST::List.new(
          hash.map do |cur_key, cur_value|
            local.register_variable!(key, cur_key)
            local.register_variable!(value, cur_value)
            expression.simplified(local)
          end
        )
      end
    end
  end
end

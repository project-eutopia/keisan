require "keisan/functions/enumerable_function"

module Keisan
  module Functions
    class Filter < EnumerableFunction
      # Filters lists/hashes:
      # (list, variable, boolean_expression)
      # (hash, key, value, boolean_expression)
      def initialize
        super("filter")
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
          raise Exceptions::InvalidFunctionError.new("Filter on list must take 3 arguments")
        end
        variable = arguments.first

        local = context.spawn_child(transient: false, shadowed: [variable.name])

        AST::List.new(
          list.children.select do |element|
            local.register_variable!(variable, element)
            result = expression.evaluated(local)

            case result
            when AST::Boolean
              result.value
            else
              raise Exceptions::InvalidFunctionError.new("Filter requires expression to be a logical expression, received: #{result.to_s}")
            end
          end
        )
      end

      def evaluate_hash(hash, arguments, expression, context)
        unless arguments.count == 2
          raise Exceptions::InvalidFunctionError.new("Filter on hash must take 4 arguments")
        end

        key, value = arguments[0..1]

        local = context.spawn_child(transient: false, shadowed: [key.name, value.name])

        AST::Hash.new(
          hash.select do |cur_key, cur_value|
            local.register_variable!(key, cur_key)
            local.register_variable!(value, cur_value)
            result = expression.evaluated(local)

            case result
            when AST::Boolean
              result.value
            else
              raise Exceptions::InvalidFunctionError.new("Filter requires expression to be a logical expression, received: #{result.to_s}")
            end
          end
        )
      end
    end
  end
end

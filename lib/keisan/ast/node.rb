module Keisan
  module AST
    class Node
      def value(context = nil)
        raise Keisan::Exceptions::NotImplementedError.new
      end

      def unbound_variables(context = nil)
        context ||= Keisan::Context.new

        case self
        when Parent
          children.inject(Set.new) do |vars, child|
            vars | child.unbound_variables(context)
          end
        else
          Set.new
        end
      end

      def unbound_functions(context = nil)
        context ||= Keisan::Context.new

        case self
        when Parent
          children.inject(Set.new) do |fns, child|
            fns | child.unbound_functions(context)
          end
        else
          Set.new
        end
      end
    end
  end
end

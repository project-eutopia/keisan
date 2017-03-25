module Keisan
  module AST
    class Node
      def value(context = nil)
        raise Keisan::Exceptions::NotImplementedError.new
      end

      def unbound_variables(context = nil)
        Set.new
      end

      def unbound_functions(context = nil)
        Set.new
      end

      def simplified(context = nil)
        deep_dup.simplify(context)
      end

      def simplify(context = nil)
        self
      end

      def deep_dup
        dup
      end
    end
  end
end

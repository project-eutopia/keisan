module Keisan
  module Functions
    class Break < Function
      def initialize
        super("break", 0)
      end

      def value(ast_function, context = nil)
        raise Exceptions::BreakError.new
      end

      def evaluate(ast_function, context = nil)
        raise Exceptions::BreakError.new
      end

      def simplify(ast_function, context = nil)
        raise Exceptions::BreakError.new
      end
    end
  end
end

module Keisan
  module Functions
    class Continue < Function
      def initialize
        super("continue", 0)
      end

      def value(ast_function, context = nil)
        raise Exceptions::ContinueError.new
      end

      def evaluate(ast_function, context = nil)
        raise Exceptions::ContinueError.new
      end

      def simplify(ast_function, context = nil)
        raise Exceptions::ContinueError.new
      end
    end
  end
end

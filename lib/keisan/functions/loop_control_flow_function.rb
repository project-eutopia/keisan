module Keisan
  module Functions
    class LoopControlFlowFuntion < Function
      def initialize(name, exception_class)
        super(name, 0)
        @exception_class = exception_class
      end

      def value(ast_function, context = nil)
        raise @exception_class.new
      end

      def evaluate(ast_function, context = nil)
        raise @exception_class.new
      end

      def simplify(ast_function, context = nil)
        raise @exception_class.new
      end
    end
  end
end

module Keisan
  module Functions
    class ExpressionFunction < Keisan::Function
      attr_reader :expression

      def initialize(name, function_proc, expression)
        super(name, function_proc)
        @expression = expression
      end
    end
  end
end

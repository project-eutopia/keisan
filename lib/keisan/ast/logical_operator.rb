module Keisan
  module AST
    class LogicalOperator < Operator
      def evaluate(context = nil)
        context ||= Context.new
        children[0].evaluate(context).send(operator, children[1].evaluate(context))
      end

      def simplify(context = nil)
        context ||= Context.new
        children[0].simplify(context).send(operator, children[1].simplify(context))
      end

      def value(context=nil)
        context ||= Context.new
        children[0].value(context).send(value_operator, children[1].value(context))
      end

      protected

      def value_operator
        raise Exceptions::NotImplementedError.new
      end

      def operator
        raise Exceptions::NotImplementedError.new
      end
    end
  end
end

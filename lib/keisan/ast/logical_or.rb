module Keisan
  module AST
    class LogicalOr < LogicalOperator
      def self.symbol
        :"||"
      end

      def blank_value
        false
      end

      def evaluate(context = nil)
        short_circuit_do(:evaluate, context)
      end

      def simplify(context = nil)
        short_circuit_do(:simplify, context)
      end

      def value(context = nil)
        context ||= Context.new
        children[0].value(context) || children[1].value(context)
      end

      private

      def short_circuit_do(method, context)
        context ||= Context.new
        lhs = children[0].send(method, context)
        case lhs
        when AST::Boolean
          lhs.true? ? AST::Boolean.new(true) : children[1].send(method, context)
        else
          lhs.or(children[1].send(method, context))
        end
      end
    end
  end
end

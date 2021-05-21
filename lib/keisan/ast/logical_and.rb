module Keisan
  module AST
    class LogicalAnd < LogicalOperator
      def self.symbol
        :"&&"
      end

      def blank_value
        true
      end

      def evaluate(context = nil)
        short_circuit_do(:evaluate, context)
      end

      def simplify(context = nil)
        short_circuit_do(:simplify, context)
      end

      def value(context = nil)
        context ||= Context.new
        children[0].value(context) && children[1].value(context)
      end

      private

      def short_circuit_do(method, context)
        context ||= Context.new
        lhs = children[0].send(method, context).to_node
        case lhs
        when AST::Boolean
          lhs.false? ? AST::Boolean.new(false) : children[1].send(method, context)
        else
          lhs.and(children[1].send(method, context))
        end
      end
    end
  end
end

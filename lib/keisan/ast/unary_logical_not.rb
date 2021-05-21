module Keisan
  module AST
    class UnaryLogicalNot < UnaryOperator
      def value(context = nil)
        return !child.value(context)
      end

      def self.symbol
        :"!"
      end

      def evaluate(context = nil)
        context ||= Context.new
        node = child.evaluate(context).to_node
        case node
        when AST::Boolean
          AST::Boolean.new(!node.value)
        else
          if node.is_constant?
            raise Keisan::Exceptions::InvalidFunctionError.new("Cannot take unary logical not of non-boolean constant")
          else
            super
          end
        end
      end

      def simplify(context = nil)
        context ||= Context.new
        node = child.simplify(context).to_node
        case node
        when AST::Boolean
          AST::Boolean.new(!node.value)
        else
          super
        end
      end
    end
  end
end

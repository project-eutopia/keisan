module Keisan
  module AST
    class UnaryPlus < UnaryIdentity
      def value(context = nil)
        return children.first.value(context)
      end

      def self.symbol
        :"+"
      end

      def simplify(context = nil)
        case child
        when AST::Number
          AST::Number.new(child.value(context)).simplify(context)
        else
          super
        end
      end

      def differentiate(variable, context = nil)
        child.differentiate(variable, context)
      end
    end
  end
end

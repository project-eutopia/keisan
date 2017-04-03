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
    end
  end
end

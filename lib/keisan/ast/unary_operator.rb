module Keisan
  module AST
    class UnaryOperator < Operator
      def initialize(children = [])
        children = Array.wrap(children)
        super
        if children.count != 1
          raise Keisan::Exceptions::ASTError.new("Unary operator takes has a single child")
        end
      end

      def child
        children.first
      end

      def self.arity
        ARITIES[:"u#{symbol}"]
      end

      def self.priority
        PRIORITIES[:"u#{symbol}"]
      end

      def self.associativity
        ASSOCIATIVITIES[:"u#{symbol}"]
      end

      def to_s
        "#{symbol.to_s}#{child.to_s}"
      end

      def simplify(context = nil)
        self
      end
    end
  end
end

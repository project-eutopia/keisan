module SymbolicMath
  module AST
    class Parent < Node
      attr_reader :children

      def initialize(children = [])
        children = Array.wrap(children)
        unless children.is_a?(Array) && children.all? {|children| children.is_a?(Node)}
          raise SymbolicMath::Exceptions::InternalError.new
        end
        @children = children
      end
    end
  end
end

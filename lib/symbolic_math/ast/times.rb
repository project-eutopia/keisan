module SymbolicMath
  module AST
    class Times < Operator
      def self.priority
        20
      end

      def value(context = nil)
        children.inject(1) do |product, child|
          product * child.value(context)
        end
      end
    end
  end
end

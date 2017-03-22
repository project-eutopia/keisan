module SymbolicMath
  module AST
    class Plus < Operator
      def self.priority
        10
      end

      def value(context = nil)
        children.inject(0) do |sum, child|
          sum + child.value(context)
        end
      end
    end
  end
end

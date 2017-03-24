module SymbolicMath
  module AST
    class List < Parent
      def value(context = nil)
        context = SymbolicMath::Context.new if context.nil?
        children.map {|child| child.value(context)}
      end
    end
  end
end

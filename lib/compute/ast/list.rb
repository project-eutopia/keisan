module Compute
  module AST
    class List < Parent
      def value(context = nil)
        context = Compute::Context.new if context.nil?
        children.map {|child| child.value(context)}
      end
    end
  end
end

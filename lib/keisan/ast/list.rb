module Keisan
  module AST
    class List < Parent
      def value(context = nil)
        context ||= Keisan::Context.new
        children.map {|child| child.value(context)}
      end

      def to_s
        "[#{children.map(&:to_s).join(',')}]"
      end
    end
  end
end

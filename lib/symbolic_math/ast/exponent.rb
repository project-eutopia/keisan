module SymbolicMath
  module AST
    class Exponent < Operator
      def self.priority
        30
      end

      def initialize(children = [])
        super
        # TODO use better exception
        raise SymbolicMath::Exponent::InternalError.new unless children.count >= 2
      end

      def value(context = nil)
        children.reverse.inject(1) do |result, child|
          child.value(context) ** result
        end
      end
    end
  end
end

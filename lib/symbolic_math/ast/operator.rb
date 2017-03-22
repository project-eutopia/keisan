module SymbolicMath
  module AST
    class Operator < Parent
      def initialize(children = [], parsing_operators = [])
        unless children.count == parsing_operators.count + 1
          raise SymbolicMath::Exceptions::ASTError.new("Mismatch of children and operators")
        end

        unless arity.include?(children.count)
          raise SymbolicMath::Exceptions::ASTError.new("Invalid number of arguments")
        end

        children = Array.wrap(children)
        super(children)

        @parsing_operators = parsing_operators
      end


      def arity
        raise SymbolicMath::Exceptions::NotImplementedError.new
      end
    end
  end
end

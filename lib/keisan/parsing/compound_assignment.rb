module Keisan
  module Parsing
    class CompoundAssignment < Operator
      attr_reader :compound_operator

      def initialize(compound_operator)
        @compound_operator = compound_operator
      end

      def node_class
        AST::Assignment
      end
    end
  end
end

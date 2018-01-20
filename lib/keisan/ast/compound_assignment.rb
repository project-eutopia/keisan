module Keisan
  module AST
    class CompoundAssignment < Operator
      attr_reader :local

      def initialize(children = [], parsing_operators = [], local: false)
        super(children, parsing_operators)
        @local = local
      end
    end
  end
end

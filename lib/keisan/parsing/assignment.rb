module Keisan
  module Parsing
    class Assignment < Operator
      def node_class
        AST::Assignment
      end
    end
  end
end

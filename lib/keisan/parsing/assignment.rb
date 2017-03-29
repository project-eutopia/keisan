module Keisan
  module Parsing
    class Assignment < Operator
      def node_class
        Keisan::AST::Assignment
      end
    end
  end
end

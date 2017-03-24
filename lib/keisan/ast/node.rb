module Keisan
  module AST
    class Node
      def value(context = nil)
        raise Keisan::Exceptions::NotImplementedError.new
      end
    end
  end
end

module Keisan
  module Functions
    class Real < CMathFunction
      def initialize
        super("real", Proc.new {|arg| arg.real})
      end
    end
  end
end

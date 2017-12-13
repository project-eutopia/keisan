module Keisan
  module Functions
    class Abs < CMathFunction
      def initialize
        super("abs", Proc.new {|arg| arg.abs})
      end
    end
  end
end

module Keisan
  module Functions
    class Imag < CMathFunction
      def initialize
        super("imag", Proc.new {|arg| arg.imag})
      end
    end
  end
end

require "cmath"

module Keisan
  module Functions
    class CMathFunction < MathFunction
      def initialize(name, proc_function = nil)
        super(name, proc_function || Proc.new {|arg| CMath.send(name, arg)})
      end
    end
  end
end

module Compute
  module Functions
    class Sin < Compute::Function
      def initialize
        @name = "sin"
        @function_proc = Proc.new {|theta| Math.sin(theta)}
      end
    end
  end
end

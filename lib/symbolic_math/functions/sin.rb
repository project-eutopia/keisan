module SymbolicMath
  module Functions
    class Sin < SymbolicMath::Function
      def initialize
        @name = "sin"
        @function_proc = Proc.new {|theta| Math.sin(theta)}
      end
    end
  end
end

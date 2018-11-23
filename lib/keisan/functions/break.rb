require_relative "loop_control_flow_function"

module Keisan
  module Functions
    class Break < LoopControlFlowFuntion
      def initialize
        super("break", Exceptions::BreakError)
      end
    end
  end
end

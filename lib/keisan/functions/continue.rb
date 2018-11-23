require_relative "loop_control_flow_function"

module Keisan
  module Functions
    class Continue < LoopControlFlowFuntion
      def initialize
        super("continue", Exceptions::ContinueError)
      end
    end
  end
end

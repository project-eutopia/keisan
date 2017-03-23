module SymbolicMath
  class Function
    attr_reader :name

    def initialize(name, function_proc)
      raise SymbolicMath::Exceptions::InvalidFunctionError.new unless function_proc.is_a?(Proc)
      @name = name
      @function_proc = function_proc
    end

    def call(*args)
      @function_proc.call(*args)
    end
  end
end

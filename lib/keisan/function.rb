module Keisan
  class Function
    attr_reader :name

    def initialize(name, function_proc)
      raise Keisan::Exceptions::InvalidFunctionError.new unless function_proc.is_a?(Proc)
      @name = name
      @function_proc = function_proc
    end

    def call(context, *args)
      @function_proc.call(*args)
    end
  end
end

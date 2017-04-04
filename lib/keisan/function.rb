module Keisan
  class Function
    attr_reader :name

    def initialize(name)
      @name = name
    end

    def value(ast_function, context = nil)
      raise Keisan::Exceptions::NotImplementedError.new
    end

    def evaluate(ast_function, context = nil)
      raise Keisan::Exceptions::NotImplementedError.new
    end

    def simplify(ast_function, context = nil)
      raise Keisan::Exceptions::NotImplementedError.new
    end
  end
end

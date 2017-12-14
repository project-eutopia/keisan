module Keisan
  class Function
    attr_reader :name, :arity

    def initialize(name, arity = 1)
      @name = name
      @arity = arity
    end

    def value(ast_function, context = nil)
      raise Exceptions::NotImplementedError.new
    end

    def evaluate(ast_function, context = nil)
      raise Exceptions::NotImplementedError.new
    end

    def simplify(ast_function, context = nil)
      raise Exceptions::NotImplementedError.new
    end

    def differentiate(ast_function, variable, context = nil)
      raise Exceptions::NotImplementedError.new
    end

    protected

    def validate_arguments!(count)
      case arity
      when Integer
        if arity < 0 && count < arity.abs || arity >= 0 && count != arity
          raise Keisan::Exceptions::InvalidFunctionError.new("Require #{arity} arguments to #{name}")
        end
      when Range
        unless arity.include? count
          raise Keisan::Exceptions::InvalidFunctionError.new("Require #{arity} arguments to #{name}")
        end
      else
        raise Keisan::Exceptions::InternalError.new("Invalid arity: #{arity}")
      end
    end
  end
end

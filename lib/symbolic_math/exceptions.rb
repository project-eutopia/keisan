module SymbolicMath
  module Exceptions
    class BaseError < StandardError; end

    class InternalError < BaseError; end
    class NotImplementedError < InternalError; end

    class InvalidToken < BaseError; end
    class TokenizingError < BaseError; end
    class ParseError < BaseError; end
    class ASTError < BaseError; end
    class InvalidFunctionError < BaseError; end
    class UndefinedFunctionError < BaseError; end
    class UndefinedVariableError < BaseError; end
  end
end

module SymbolicMath
  module Exceptions
    class BaseError < StandardError; end
    class InternalError < BaseError; end

    class InvalidToken < BaseError; end
    class NotImplementedError < BaseError; end
    class TokenizingError < BaseError; end
    class ParseError < BaseError; end
  end
end

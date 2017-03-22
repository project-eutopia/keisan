module SymbolicMath
  module Exceptions
    class BaseError < StandardError; end
    class InvalidToken < BaseError; end
    class NotImplementedError < BaseError; end
    class TokenizingError < BaseError; end
  end
end

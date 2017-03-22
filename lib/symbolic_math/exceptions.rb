module SymbolicMath
  module Exceptions
    class BaseError < StandardError; end
    class InvalidToken < BaseError; end
    class NotImplementedError < BaseError; end
  end
end

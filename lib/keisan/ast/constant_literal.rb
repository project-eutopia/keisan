module Keisan
  module AST
    class ConstantLiteral < Literal
      def self.from_value(value)
        case value
        when Numeric
          AST::Number.new(value)
        when ::String
          AST::String.new(value)
        when TrueClass, FalseClass
          AST::Boolean.new(value)
        when NilClass
          AST::Null.new
        else
          raise TypeError.new("#{value}'s type is invalid, #{value.class}")
        end
      end

      def coerce(other)
        [self, self.class.from_value(other)]
      end

      def to_s
        value.to_s
      end
    end
  end
end

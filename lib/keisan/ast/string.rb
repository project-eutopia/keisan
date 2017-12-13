module Keisan
  module AST
    class String < ConstantLiteral
      attr_reader :content

      def initialize(content)
        @content = content
      end

      def value(context = nil)
        content
      end

      def +(other)
        case other
        when AST::String
          AST::String.new(value + other.value)
        else
          raise Keisan::Exceptions::TypeError.new("#{other}'s type is invalid, #{other.class}")
        end
      end

      def to_s
        if value =~ /\"/
          "\"#{value.gsub("\"", "\\\"")}\""
        else
          "\"#{value}\""
        end
      end
    end
  end
end

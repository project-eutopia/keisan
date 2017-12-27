module Keisan
  module Parsing
    class Hash < Element
      attr_reader :key_value_pairs

      def initialize(key_value_pairs)
        @key_value_pairs = Array.wrap(key_value_pairs).map {|key_value_pair|
          key, value = key_value_pair.split {|token| token.is_a?(Tokens::Colon)}
          raise Exceptions::ParseError.new("Invalid hash") unless key.size == 1 && value.size >= 1

          key = key.first
          raise Exceptions::ParseError.new("Invalid hash (keys must be strings)") unless key.is_a?(Tokens::String)
          [Parsing::String.new(key.value), Parsing::RoundGroup.new(value)]
        }
      end
    end
  end
end

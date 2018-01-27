module Keisan
  module AST
    class Hash < Node
      include Enumerable

      def initialize(key_value_pairs)
        @hash = ::Hash[key_value_pairs.map(&:to_a).map {|k,v| [k.value, v.to_node]}]
      end

      def [](key)
        key = key.to_node
        return nil unless key.is_a?(AST::ConstantLiteral)

        @hash[key.value] || Cell.new(Null.new).tap do |cell|
          @hash[key.value] = cell
        end
      end

      def evaluate(context = nil)
        context ||= Context.new

        @hash = ::Hash[
          @hash.map do |key, val|
            if val.is_a?(Cell)
              [key, val]
            else
              [key, val.evaluate(context)]
            end
          end
        ]

        self
      end

      def simplify(context = nil)
        evaluate(context)
      end

      def each(&block)
        @hash.each(&block)
      end

      def keys
        @hash.keys
      end

      def values
        @hash.values
      end

      def value(context = nil)
        context ||= Context.new
        evaluate(context)

        ::Hash[
          @hash.map {|key, val|
            [key, val.value(context)]
          }
        ]
      end

      def to_s
        "{#{@hash.map {|k,v| "#{k.is_a?(::String) ? "'#{k}'" : k}: #{v}"}.join(', ')}}"
      end

      def to_cell
        h = self.class.new([])
        h.instance_variable_set(:@hash, ::Hash[
          @hash.map do |key, value|
            [key, value.to_cell]
          end
        ])
        AST::Cell.new(h)
      end
    end
  end
end

module Keisan
  module AST
    class Hash < Node
      def initialize(key_value_pairs)
        @hash = ::Hash[key_value_pairs]
        valueify_and_cellify!
      end

      def [](key)
        key = key.to_node
        return nil unless key.is_a?(AST::ConstantLiteral)

        if val = @hash[key.value]
          val
        else
          Cell.new(Null.new).tap do |cell|
            @hash[key.value] = cell
          end
        end
      end

      def evaluate(context = nil)
        context ||= Context.new
        valueify_and_cellify!

        @hash = ::Hash[
          @hash.map do |key, val|
            if val.is_a?(Cell)
              [key, val]
            else
              [key, Cell.new(val.evaluate(context))]
            end
          end
        ]

        self
      end

      def simplify(context = nil)
        evaluate(context)
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
        "{#{@hash.map {|k,v| "'#{k}': #{v}"}.join(', ')}}"
      end

      def to_cell
        h = self.class.new([])
        h.instance_variable_set(:@hash, ::Hash[
          @hash.map do |key, value|
            [key, value.to_cell]
          end
        ])
        h
      end

      private

      def valueify_and_cellify!
        @hash = ::Hash[
          @hash.map do |key, val|
            key = key.value
            val = Cell.new(val) unless val.is_a?(Cell)
            [key, val]
          end
        ]
      end
    end
  end
end

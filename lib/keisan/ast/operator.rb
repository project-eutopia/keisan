module Keisan
  module AST
    class Operator < Parent
      # NOTE: operators with same priority must have same associativity
      ARITY_PRIORITY_ASSOCIATIVITY = {
        "u!": [1, 100, :right],
        "u~": [1, 100, :right],
        "u+": [1, 100, :right],
        "**": [2,  95, :right],
        "u-": [1,  90, :right],
        "*":  [2,  85, :left],
        # "/":  [2,  85, :left],
        "%":  [2,  85, :left],
        "+":  [2,  80, :left],
        # "-":  [2,  80, :left],
        "&":  [2,  70, :left],
        "^":  [2,  65, :left],
        "|":  [2,  65, :left],
        ">":  [2,  60, :left],
        ">=": [2,  60, :left],
        "<":  [2,  60, :left],
        "<=": [2,  60, :left],
        "==": [2,  55, :none],
        "!=": [2,  55, :none],
        "&&": [2,  50, :left],
        "||": [2,  45, :left],
        "=":  [2,  40, :right] # TODO: handle and test
      }.freeze

      ARITIES         = Hash[ARITY_PRIORITY_ASSOCIATIVITY.map {|sym, ary| [sym, ary[0]]}].freeze
      PRIORITIES      = Hash[ARITY_PRIORITY_ASSOCIATIVITY.map {|sym, ary| [sym, ary[1]]}].freeze
      ASSOCIATIVITIES = Hash[ARITY_PRIORITY_ASSOCIATIVITY.map {|sym, ary| [sym, ary[2]]}].freeze

      ASSOCIATIVITY_OF_PRIORITY = ARITY_PRIORITY_ASSOCIATIVITY.inject({}) do |h, (symbol,arity_priority_associativity)|
        h[arity_priority_associativity[1]] = arity_priority_associativity[2]
        h
      end.freeze

      def initialize(children = [], parsing_operators = [])
        unless parsing_operators.empty? || children.count == parsing_operators.count + 1
          raise Keisan::Exceptions::ASTError.new("Mismatch of children and operators")
        end

        children = Array.wrap(children)
        super(children)

        @parsing_operators = parsing_operators
      end

      def self.associativity_of_priority(priority)
        ASSOCIATIVITY_OF_PRIORITY[priority]
      end

      def arity
        self.class.arity
      end

      def self.arity
        ARITIES[symbol]
      end

      def priority
        self.class.priority
      end

      def self.priority
        PRIORITIES[symbol]
      end

      def associativity
        self.class.associativity
      end

      def self.associativity
        ASSOCIATIVITIES[symbol]
      end

      def symbol
        self.class.symbol
      end

      def self.symbol
        raise Keisan::Exceptions::NotImplementedError.new
      end

      def blank_value
        raise Keisan::Exceptions::NotImplementedError.new
      end

      def value(context = nil)
        args = children
        args = args.reverse if associativity == :right

        args.inject(blank_value) do |result, child|
          if associativity == :left
            result.send(symbol, child.value(context))
          else
            child.value(context).send(symbol, result)
          end
        end
      end

      def to_s
        children.map do |child|
          case child
          when AST::Operator
            "(#{child.to_s})"
          else
            "#{child.to_s}"
          end
        end.join(symbol.to_s)
      end
    end
  end
end

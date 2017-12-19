module Keisan
  module AST
    class Operator < Parent
      # NOTE: operators with same priority must have same associativity
      ARITY_PRIORITY_ASSOCIATIVITY = {
        "u!": [1, 100, :right],  # Logical not
        "u~": [1, 100, :right],  # Bitwise not
        "u+": [1, 100, :right],  # Unary plus
        "**": [2,  95, :right],  # Exponent
        "u-": [1,  90, :right],  # Unary minus
        "*":  [2,  85, :left],   # Times
        # "/":  [2,  85, :left], # Divide
        "%":  [2,  85, :left],   # Modulo
        "+":  [2,  80, :left],   # Plus
        # "-":  [2,  80, :left], # Minus
        "&":  [2,  70, :left],   # Bitwise and
        "^":  [2,  65, :left],   # Bitwise xor
        "|":  [2,  65, :left],   # Bitwise or
        ">":  [2,  60, :left],   # Greater than
        ">=": [2,  60, :left],   # Greater than or equal to
        "<":  [2,  60, :left],   # Less than
        "<=": [2,  60, :left],   # Less than or equal to
        "==": [2,  55, :none],   # Equal
        "!=": [2,  55, :none],   # Not equal
        "&&": [2,  50, :left],   # Logical and
        "||": [2,  45, :left],   # Logical or
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
          raise Exceptions::ASTError.new("Mismatch of children and operators")
        end

        children = Array.wrap(children)
        super(children)

        @parsing_operators = parsing_operators
      end

      def evaluate_assignments(context = nil)
        context ||= Context.new
        @children = children.map do |child|
          child.evaluate_assignments(context)
        end
        self
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
        raise Exceptions::NotImplementedError.new
      end

      def blank_value
        raise Exceptions::NotImplementedError.new
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
          when Operator
            "(#{child.to_s})"
          else
            "#{child.to_s}"
          end
        end.join(symbol.to_s)
      end
    end
  end
end

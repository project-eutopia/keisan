module Keisan
  module Functions
    class Range < Keisan::Function
      def initialize
        super("range", ::Range.new(1,3))
      end

      def call(context, *args)
        case args.count
        when 1
          (0...args[0]).to_a
        when 2
          (args[0]...args[1]).to_a
        when 3
          current = args[0]
          final = args[1]
          shift = args[2]

          if shift == 0 or !shift.is_a?(Integer)
            raise Keisan::Exceptions::InvalidFunctionError.new("range's 3rd argument must be non-zero integer")
          end

          result = []

          if shift > 0
            while current < final
              result << current
              current += shift
            end
          else
            while current > final
              result << current
              current += shift
            end
          end

          result
        else
          raise Keisan::Exceptions::InvalidFunctionError.new("range takes 1 to 3 arguments")
        end
      end

      def value(ast_function, context = nil)
        validate_arguments!(ast_function.children.count)
        evaluate(ast_function, context)
      end

      def evaluate(ast_function, context = nil)
        validate_arguments!(ast_function.children.count)
        context ||= Keisan::Context.new
        simplify(ast_function, context)
      end

      def simplify(ast_function, context = nil)
        validate_arguments!(ast_function.children.count)
        context ||= Context.new

        simplified_children = ast_function.children.map {|child| child.simplify(context)}

        if simplified_children.all? {|child| child.is_a?(Keisan::AST::Number)}
          Keisan::AST::List.new(call(context, *simplified_children.map(&:value)))
        else
          Keisan::AST::Function.new(simplified_children, "range")
        end
      end
    end
  end
end

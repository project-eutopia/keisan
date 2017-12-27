module Keisan
  module Functions
    class Range < Function
      def initialize
        super("range", ::Range.new(1,3))
      end

      def call(context, *args)
        start, finish, shift = start_finish_shift_from_args(*args)

        if shift == 1
          start_finish_range(start, finish)
        else
          start_finish_shift_range(start, finish, shift)
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

      private

      def start_finish_shift_from_args(*args)
        case args.count
        when 1
          [0, args[0], 1]
        when 2
          [args[0], args[1], 1]
        when 3
          [args[0], args[1], args[2]]
        else
          [0, 0, 0]
        end
      end

      def start_finish_range(start, finish)
        (start...finish).to_a
      end

      def start_finish_shift_range(start, finish, shift)
        if shift == 0 or !shift.is_a?(Integer)
          raise Keisan::Exceptions::InvalidFunctionError.new("shift argument for Range must be non-zero integer")
        end

        if shift > 0
          (start...finish).select {|i| (i - start) % shift == 0}
        else
          (finish+1...start+1).select {|i| (i - finish) % shift == 0}.reverse
        end
      end
    end
  end
end

require_relative "if"
require_relative "while"
require_relative "diff"
require_relative "replace"
require_relative "map"
require_relative "filter"
require_relative "reduce"
require_relative "rand"
require_relative "sample"
require_relative "math_function"
require_relative "cmath_function"
require_relative "exp"
require_relative "log"
require_relative "sin"
require_relative "cos"
require_relative "sec"
require_relative "tan"
require_relative "cot"
require_relative "csc"
require_relative "sinh"
require_relative "cosh"
require_relative "sech"
require_relative "tanh"
require_relative "coth"
require_relative "csch"
require_relative "sqrt"
require_relative "cbrt"
require_relative "abs"
require_relative "real"
require_relative "imag"

module Keisan
  module Functions
    class DefaultRegistry
      def self.registry
        @registry ||= Registry.new.tap do |r|
          register_defaults!(r)
        end.freeze
      end

      private

      def self.register_defaults!(registry)
        registry.register!(:if, If.new, force: true)
        registry.register!(:while, While.new, force: true)
        registry.register!(:diff, Diff.new, force: true)
        registry.register!(:replace, Replace.new, force: true)
        registry.register!(:map, Map.new, force: true)
        registry.register!(:collect, Map.new, force: true)
        registry.register!(:filter, Filter.new, force: true)
        registry.register!(:select, Filter.new, force: true)
        registry.register!(:reduce, Reduce.new, force: true)
        registry.register!(:inject, Reduce.new, force: true)

        register_builtin_math!(registry)
        register_array_methods!(registry)
        register_random_methods!(registry)

        registry.register!(:exp, Exp.new, force: true)
        registry.register!(:log, Log.new, force: true)

        registry.register!(:sin, Sin.new, force: true)
        registry.register!(:cos, Cos.new, force: true)
        registry.register!(:tan, Tan.new, force: true)
        registry.register!(:cot, Cot.new, force: true)
        registry.register!(:sec, Sec.new, force: true)
        registry.register!(:csc, Csc.new, force: true)

        registry.register!(:sinh, Sinh.new, force: true)
        registry.register!(:cosh, Cosh.new, force: true)
        registry.register!(:tanh, Tanh.new, force: true)
        registry.register!(:coth, Coth.new, force: true)
        registry.register!(:sech, Sech.new, force: true)
        registry.register!(:csch, Csch.new, force: true)

        registry.register!(:sqrt, Sqrt.new, force: true)
        registry.register!(:cbrt, Cbrt.new, force: true)

        registry.register!(:abs, Abs.new, force: true)
        registry.register!(:real, Real.new, force: true)
        registry.register!(:imag, Imag.new, force: true)
      end

      def self.register_builtin_math!(registry)
        Math.methods(false).each do |method|
          registry.register!(
            method,
            Proc.new {|*args|
              args = args.map(&:value)
              Math.send(method, *args)
            },
            force: true
          )
        end
      end

      def self.register_array_methods!(registry)
        %i(min max size flatten reverse).each do |method|
          registry.register!(method, Proc.new {|a| a.send(method)}, force: true)
        end

        # range(10) => Integers from 0 inclusive to 10 exclusively
        # range(5, 15) => Integers from 5 inclusive to 15 exclusive
        # range(10, -1, -2) => Integers from 10 inclusive to -1 exclusive, decreasing by twos
        #   i.e.:  [10, 8, 6, 4, 2, 0]
        registry.register!("range", Proc.new {|*args|
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
              raise Exceptions::InvalidFunctionError.new("range's 3rd argument must be non-zero integer")
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
            raise Exceptions::InvalidFunctionError.new("range takes 1 to 3 arguments")
          end
        }, force: true)
      end

      def self.register_random_methods!(registry)
        registry.register!(:rand, Rand.new, force: true)
        registry.register!(:sample, Sample.new, force: true)
      end
    end
  end
end

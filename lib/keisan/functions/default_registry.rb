require_relative "if"
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
        registry.register!(:if, Keisan::Functions::If.new, force: true)
        registry.register!(:diff, Keisan::Functions::Diff.new, force: true)
        registry.register!(:replace, Keisan::Functions::Replace.new, force: true)
        registry.register!(:map, Keisan::Functions::Map.new, force: true)
        registry.register!(:collect, Keisan::Functions::Map.new, force: true)
        registry.register!(:filter, Keisan::Functions::Filter.new, force: true)
        registry.register!(:select, Keisan::Functions::Filter.new, force: true)
        registry.register!(:reduce, Keisan::Functions::Reduce.new, force: true)
        registry.register!(:inject, Keisan::Functions::Reduce.new, force: true)

        register_builtin_math!(registry)
        register_array_methods!(registry)
        register_random_methods!(registry)

        registry.register!(:exp, Keisan::Functions::Exp.new, force: true)
        registry.register!(:log, Keisan::Functions::Log.new, force: true)

        registry.register!(:sin, Keisan::Functions::Sin.new, force: true)
        registry.register!(:cos, Keisan::Functions::Cos.new, force: true)
        registry.register!(:tan, Keisan::Functions::Tan.new, force: true)
        registry.register!(:cot, Keisan::Functions::Cot.new, force: true)
        registry.register!(:sec, Keisan::Functions::Sec.new, force: true)
        registry.register!(:csc, Keisan::Functions::Csc.new, force: true)

        registry.register!(:sinh, Keisan::Functions::Sinh.new, force: true)
        registry.register!(:cosh, Keisan::Functions::Cosh.new, force: true)
        registry.register!(:tanh, Keisan::Functions::Tanh.new, force: true)
        registry.register!(:coth, Keisan::Functions::Coth.new, force: true)
        registry.register!(:sech, Keisan::Functions::Sech.new, force: true)
        registry.register!(:csch, Keisan::Functions::Csch.new, force: true)

        registry.register!(:sqrt, Keisan::Functions::Sqrt.new, force: true)
        registry.register!(:cbrt, Keisan::Functions::Cbrt.new, force: true)

        registry.register!(:abs, Keisan::Functions::Abs.new, force: true)
        registry.register!(:real, Keisan::Functions::Real.new, force: true)
        registry.register!(:imag, Keisan::Functions::Imag.new, force: true)
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
        }, force: true)
      end

      def self.register_random_methods!(registry)
        registry.register!(:rand, Keisan::Functions::Rand.new, force: true)
        registry.register!(:sample, Keisan::Functions::Sample.new, force: true)
      end
    end
  end
end

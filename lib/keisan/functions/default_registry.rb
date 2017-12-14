require_relative "let"

require_relative "if"
require_relative "while"
require_relative "diff"
require_relative "replace"
require_relative "range"
require_relative "map"
require_relative "filter"
require_relative "reduce"
require_relative "rand"
require_relative "sample"
require_relative "math_function"
require_relative "cmath_function"
require_relative "erf"
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
        registry.register!(:let, Let.new, force: true)

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

        register_math!(registry)
        register_array_methods!(registry)
        register_random_methods!(registry)
      end

      def self.register_math!(registry)
        register_builtin_math!(registry)
        register_custom_math!(registry)
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

      CUSTOM_MATH_FUNCTIONS = %i(erf exp log sin cos tan cot sec csc sinh cosh tanh coth sech csch sqrt cbrt abs real imag).freeze

      def self.register_custom_math!(registry)
        factorial = Proc.new {|n|
          (1..n).inject(1) do |res, i|
            res * i
          end
        }
        nPk = Proc.new {|n, k|
          factorial.call(n) / factorial.call(n-k)
        }
        nCk = Proc.new {|n, k|
          factorial.call(n) / factorial.call(k) / factorial.call(n-k)
        }

        registry.register!(:factorial, factorial, force: true)
        registry.register!(:nPk, nPk, force: true)
        registry.register!(:permute, nPk, force: true)
        registry.register!(:nCk, nCk, force: true)
        registry.register!(:choose, nCk, force: true)

        CUSTOM_MATH_FUNCTIONS.each do |method|
          klass = Keisan::Functions.const_get(method.to_s.capitalize)
          registry.register!(method, klass.new, force: true)
        end
      end

      def self.register_array_methods!(registry)
        %i(min max size flatten reverse).each do |method|
          registry.register!(method, Proc.new {|a| a.send(method)}, force: true)
        end

        registry.register!("range", Functions::Range.new, force: true)
      end

      def self.register_random_methods!(registry)
        registry.register!(:rand, Rand.new, force: true)
        registry.register!(:sample, Sample.new, force: true)
      end
    end
  end
end

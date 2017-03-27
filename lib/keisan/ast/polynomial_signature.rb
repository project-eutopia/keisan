module Keisan
  module AST
    class PolynomialSignature < Hash
      class << self
        alias new []
      end

      def +(other)
        {}
      end

      def *(other)
        self.class.new(
          other.inject(self.dup) do |res, (name, signature)|
            if res.has_key?(name)
              res[name] += signature
            else
              res[name] = signature
            end

            res
          end
        )
      end

      def **(other)
        case other
        when Numeric
          self.class.new(
            inject({}) do |res, (name, signature)|
              res[name] = other*signature
              res
            end
          )
        else
          self.class.new
        end
      end
    end
  end
end

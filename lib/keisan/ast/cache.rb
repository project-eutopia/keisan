module Keisan
  module AST
    class Cache
      def initialize
        @cache = {}
      end

      def fetch_or_build(string)
        return @cache[string] if @cache.has_key?(string)

        build_from_scratch(string).tap do |ast|
          unless frozen?
            # Freeze the AST to keep it from changing in the cache
            ast.freeze
            @cache[string] = ast
          end
        end
      end

      def has_key?(string)
        @cache.has_key?(string)
      end

      private

      def build_from_scratch(string)
        Builder.new(string: string).ast
      end
    end
  end
end

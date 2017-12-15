module Keisan
  module AST
    class Builder
      # Build from parser
      def initialize(string: nil, parser: nil, components: nil)
        if [string, parser, components].select(&:nil?).size != 2
          raise Exceptions::InternalError.new("Require one of string, parser or components")
        end

        if !string.nil?
          @components = Parser.new(string: string).components
        elsif !parser.nil?
          @components = parser.components
        else
          @components = Array.wrap(components)
        end

        @lines = @components.split {|component|
          component.is_a?(Parsing::LineSeparator)
        }.reject(&:empty?)

        @line_builders = @lines.map {|line| LineBuilder.new(line)}

        if @line_builders.size == 1
          @node = @line_builders.first.ast
        else
          @node = MultiLine.new(@line_builders.map(&:ast))
        end
      end

      def node
        @node
      end

      def ast
        node
      end
    end
  end
end

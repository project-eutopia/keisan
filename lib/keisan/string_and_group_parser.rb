module Keisan
  class StringAndGroupParser
    class Portion
      attr_reader :expression, :start_index, :end_index

      def initialize(expression, start_index)
        @expression = expression
        @start_index = start_index
      end
    end

    class StringPortion < Portion
      attr_reader :string

      def initialize(expression, start_index)
        super

        @string = expression[start_index]
        index = start_index + 1

        while index < expression.size
          c = expression[index]
          if c == quote_type
            @string << c
            index += 1
            break
          end

          # escape character
          if c == "\\"
            index += 1
            if index >= expression.size
              raise Keisan::Exceptions::TokenizingError.new("Tokenizing error, no closing quote #{quote_type}")
            end
            c = expression[index]

            case c
            when "\\", '"', "'"
              @string << c
            when "a"
              @string << "\a"
            when "b"
              @string << "\b"
            when "r"
              @string << "\r"
            when "n"
              @string << "\n"
            when "s"
              @string << "\s"
            when "t"
              @string << "\t"
            else
              raise Keisan::Exceptions::TokenizingError.new("Tokenizing error, unknown escape character: \\#{c}")
            end
          else
            @string << c
          end

          index += 1
        end

        @end_index = index

        if @string.size <= 1 || @string[-1] != @string[0]
          raise Keisan::Exceptions::TokenizingError.new("Tokenizing error, no closing quote #{quote_type}")
        end
      end

      def quote_type
        @string[0]
      end

      def size
        string.size
      end

      def to_s
        string
      end
    end

    class GroupPortion < Portion
      attr_reader :opening_brace, :closing_brace ,:portions, :size

      def initialize(expression, start_index)
        super

        case expression[start_index]
        when OPEN_GROUP_REGEX
          @opening_brace = expression[start_index]

        else
          raise Keisan::Exceptions::TokenizingError.new("Internal error, GroupPortion did not start with brace")
        end

        case opening_brace
        when "("
          @closing_brace = ")"
        when "{"
          @closing_brace = "}"
        when "["
          @closing_brace = "]"
        end

        parser = StringAndGroupParser.new(expression, start_index: start_index + 1, ending_character: closing_brace)
        @portions = parser.portions
        @size = parser.size + 2

        if start_index + size > expression.size || expression[start_index + size - 1] != closing_brace
          raise Keisan::Exceptions::TokenizingError.new("Tokenizing error, group with opening brace #{opening_brace} did not have closing brace")
        end
      end

      def to_s
        opening_brace + portions.map(&:to_s).join + closing_brace
      end
    end

    class OtherPortion < Portion
      attr_reader :string

      def initialize(expression, start_index)
        super

        case expression[start_index]
        when STRING_CHARACTER_REGEX, OPEN_GROUP_REGEX, CLOSED_GROUP_REGEX
          raise Keisan::Exceptions::TokenizingError.new("Internal error, OtherPortion should not have string/braces at start")
        else
          index = start_index + 1
        end

        while index < expression.size
          case expression[index]
          when STRING_CHARACTER_REGEX, OPEN_GROUP_REGEX, CLOSED_GROUP_REGEX
            break
          else
            index += 1
          end
        end

        @end_index = index
        @string = expression[start_index...end_index]
      end

      def size
        string.size
      end

      def to_s
        string
      end
    end

    # An ordered array of "portions", which
    attr_reader :portions, :size

    STRING_CHARACTER_REGEX = /["']/
    OPEN_GROUP_REGEX = /[\(\{\[]/
    CLOSED_GROUP_REGEX = /[\)\}\]]/

    # Ending character is used as a second ending condition besides expression size
    def initialize(expression, start_index: 0, ending_character: nil)
      index = start_index
      @portions = []

      while index < expression.size && (ending_character.nil? || expression[index] != ending_character)
        case expression[index]
        when STRING_CHARACTER_REGEX
          portion = StringPortion.new(expression, index)
          index = portion.end_index
          @portions << portion

        when OPEN_GROUP_REGEX
          portion = GroupPortion.new(expression, index)
          index += portion.size
          @portions << portion

        when CLOSED_GROUP_REGEX
          raise Keisan::Exceptions::TokenizingError.new("Tokenizing error, unexpected closing brace #{expression[start_index]}")

        else
          portion = OtherPortion.new(expression, index)
          index += portion.size
          @portions << portion
        end
      end

      @size = index - start_index
    end

    def to_s
      portions.map(&:to_s).join
    end
  end
end

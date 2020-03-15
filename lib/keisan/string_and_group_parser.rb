module Keisan
  class StringAndGroupParser
    class Portion
      attr_reader :start_index, :end_index

      def initialize(start_index)
        @start_index = start_index
      end
    end

    class StringPortion < Portion
      attr_reader :string

      def initialize(expression, start_index)
        super(start_index)

        @string = expression[start_index]
        @end_index = start_index + 1

        while @end_index < expression.size
          if expression[@end_index] == quote_type
            @string << quote_type
            @end_index += 1
            # Successfully parsed the string
            return
          end

          n, c = process_next_character(expression, @end_index)
          @string << c
          @end_index += n
        end

        raise Keisan::Exceptions::TokenizingError.new("Tokenizing error, no closing quote #{quote_type}")
      end

      def size
        string.size
      end

      def to_s
        string
      end

      private

      # Returns number of processed input characters, and the output character
      def process_next_character(expression, index)
        # escape character
        if expression[index] == "\\"
          return [2, escaped_character(expression[index + 1])]
        else
          return [1, expression[index]]
        end
      end

      def quote_type
        @string[0]
      end

      def escaped_character(character)
        case character
        when "\\", '"', "'"
          character
        when "a"
          "\a"
        when "b"
          "\b"
        when "r"
          "\r"
        when "n"
          "\n"
        when "s"
          "\s"
        when "t"
          "\t"
        else
          raise Keisan::Exceptions::TokenizingError.new("Tokenizing error, unknown escape character: \"\\#{character}\"")
        end
      end
    end

    class GroupPortion < Portion
      attr_reader :opening_brace, :closing_brace ,:portions, :size

      OPENING_TO_CLOSING_BRACE = {
        "(" => ")",
        "{" => "}",
        "[" => "]",
      }

      def initialize(expression, start_index)
        super(start_index)

        case expression[start_index]
        when OPEN_GROUP_REGEX
          @opening_brace = expression[start_index]
        else
          raise Keisan::Exceptions::TokenizingError.new("Internal error, GroupPortion did not start with brace")
        end

        @closing_brace = OPENING_TO_CLOSING_BRACE[opening_brace]

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
        super(start_index)

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

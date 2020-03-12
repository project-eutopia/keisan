module Keisan
  class Tokenizer
    TOKEN_CLASSES = [
      Tokens::Null,
      Tokens::Boolean,
      Tokens::Word,
      Tokens::Number,
      Tokens::Assignment,
      Tokens::BitwiseShift,
      Tokens::LogicalOperator,
      Tokens::ArithmeticOperator,
      Tokens::BitwiseOperator,
      Tokens::Comma,
      Tokens::Colon,
      Tokens::Dot,
      Tokens::LineSeparator,
      Tokens::Unknown
    ]

    TOKEN_REGEX = Regexp::new(
      TOKEN_CLASSES.map(&:regex).join("|")
    )

    attr_reader :expression, :tokens

    def initialize(expression)
      @expression = self.class.normalize_expression(expression)
      intermediate_tokens = parse_strings_and_groups
      @tokens = intermediate_tokens.map do |sym, string|
        case sym
        when :string
          Tokens::String.new(string)
        when :group
          Tokens::Group.new(string)
        when :other
          scan = string.scan(TOKEN_REGEX)
          tokenize!(scan)
        else
          raise Keisan::Exceptions::TokenizingError.new("Internal error, unexpected symbol: #{sym}")
        end
      end.flatten
    end

    def self.normalize_expression(expression)
      expression = normalize_line_delimiters(expression)
      expression = remove_comments(expression)
    end

    private

    def parse_strings_and_groups
      braces = []
      braces_start = nil

      tokens = []

      current_other = nil
      current_string = nil

      i = 0
      while i < @expression.size
        c = @expression[i]

        if !braces.empty?
          if current_string
            # Escape character
            if c == "\\"
              i += 1
              c = @expression[i]
            # Exit string
            elsif c == current_string[0]
              current_string = nil
            end

          # Not in string
          else
            case c
            # New string
            when '"', "'"
              current_string = c
            # New opening brace
            when "(", "[", "{"
              braces << c
            # Closing brace
            when ")"
              if braces[-1] != "("
                raise Keisan::Exceptions::TokenizingError.new("Expected closing brace ')', found '#{c}'")
              end
              braces.pop
            when "]"
              if braces[-1] != "["
                raise Keisan::Exceptions::TokenizingError.new("Expected closing brace ']', found '#{c}'")
              end
              braces.pop
            when "}"
              if braces[-1] != "{"
                raise Keisan::Exceptions::TokenizingError.new("Expected closing brace '}', found '#{c}'")
              end
              braces.pop
            end
          end

          if braces.empty?
            tokens << [:group, @expression[braces_start..i]]
          end
        elsif current_string
          # Escape character
          if c == "\\"
            i += 1
            c = @expression[i]
            current_string << c
          else
            current_string << c
            # Exit string
            if c == current_string[0]
              tokens << [:string, current_string]
              current_string = nil
            end
          end
        else
          case c
          # New string
          when '"', "'"
            if current_other
              tokens << [:other, current_other]
              current_other = nil
            end

            current_string = c
          # New opening brace
          when "(", "[", "{"
            if current_other
              tokens << [:other, current_other]
              current_other = nil
            end

            braces = [c]
            braces_start = i
          # Closing brace
          when ")", "]", "}"
            raise Keisan::Exceptions::TokenizingError.new("Found unmatched closing braced '#{c}'")
          else
            current_other ||= ""
            current_other << c
          end
        end

        i += 1
      end

      if current_other
        tokens << [:other, current_other]
        current_other = nil
      end

      if !braces.empty?
        raise Keisan::Exceptions::TokenizingError.new("Found unmatched closing brace '#{braces[0]}'")
      end

      return tokens
    end

    def self.normalize_line_delimiters(expression)
      expression.gsub(/\n/, ";")
    end

    def self.remove_comments(expression)
      expression.gsub(/#[^;]*/, "")
    end

    def tokenize!(scan)
      scan.map do |scan_result|
        i = scan_result.find_index {|token| !token.nil?}
        token_string = scan_result[i]
        token = TOKEN_CLASSES[i].new(token_string)
        # binding.pry
        if token.is_a?(Tokens::Unknown)
          raise Keisan::Exceptions::TokenizingError.new("Unexpected token: \"#{token.string}\"")
        end
        token
      end
    end
  end
end

module Keisan
  class Tokenizer
    TOKEN_CLASSES = [
      Tokens::Group,
      Tokens::String,
      Tokens::Null,
      Tokens::Boolean,
      Tokens::Word,
      Tokens::Number,
      Tokens::ArithmeticOperator,
      Tokens::LogicalOperator,
      Tokens::BitwiseOperator,
      Tokens::Assignment,
      Tokens::Comma,
      Tokens::Dot,
      Tokens::LineSeparator
    ]

    TOKEN_REGEX = Regexp::new(
      TOKEN_CLASSES.map(&:regex).join("|")
    )

    attr_reader :expression, :tokens

    def initialize(expression)
      @expression = self.class.strip_whitespace_and_comments(expression)
      @scan = @expression.scan(TOKEN_REGEX)
      @tokens = tokenize!
    end

    def self.strip_whitespace_and_comments(expression)
      # Remove comments
      expression = expression.split("#").first || ""
      expression = expression.gsub(/\n/, ";")

      # Only strip whitespace outside of strings, e.g.
      # "1 + 2 + 'hello world'" => "1+2+'hello world'"
      expression.split(Tokens::String.regex).map.with_index {|s,i| i.even? ? s.gsub(/\s+/, " ") : s}.join
    end

    private

    def tokenize!
      tokenizing_check = ""

      tokens = @scan.map do |scan_result|
        i = scan_result.find_index {|token| !token.nil?}
        token_string = scan_result[i]
        tokenizing_check << token_string
        token_class = TOKEN_CLASSES[i].new(token_string)
      end

      tokens
    end
  end
end

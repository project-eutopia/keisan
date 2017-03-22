module SymbolicMath
  class Tokenizer
    TOKEN_CLASSES = [
      Tokens::Group,
      Tokens::Word,
      Tokens::Number,
      Tokens::Operator,
      Tokens::Comma
    ]

    TOKEN_REGEX = Regexp::new(
      TOKEN_CLASSES.map(&:regex).join("|")
    )

    attr_reader :expression, :tokens

    def initialize(expression)
      @expression = expression.gsub(/\s+/, "")

      @scan = @expression.scan(TOKEN_REGEX)

      @tokens = @scan.map do |scan_result|
        i = scan_result.find_index {|token| !token.nil?}
        token_class = TOKEN_CLASSES[i].new(scan_result[i])
      end
    end
  end
end

require "spec_helper"

RSpec.describe Keisan::Tokenizer do
  context "numbers" do
    context "integer" do
      it "gets integers correctly" do
        tokenizer = described_class.new("-2")

        expect(tokenizer.tokens.map(&:class)).to match_array([
          Keisan::Tokens::ArithmeticOperator,
          Keisan::Tokens::Number
        ])

        expect(tokenizer.tokens[0].string).to eq "-"
        expect(tokenizer.tokens[1].string).to eq "2"
        expect(tokenizer.tokens[1].value).to be_a Integer
        expect(tokenizer.tokens[1].value).to eq 2
      end
    end

    context "binary" do
      it "parses correctly" do
        tokenizer = described_class.new("0b1100")
        expect(tokenizer.tokens.map(&:class)).to match_array([Keisan::Tokens::Number])
        expect(tokenizer.tokens[0].string).to eq "0b1100"
        expect(tokenizer.tokens[0].value).to eq 12
      end
    end

    context "octal" do
      it "parses correctly" do
        tokenizer = described_class.new("0o775")
        expect(tokenizer.tokens.map(&:class)).to match_array([Keisan::Tokens::Number])
        expect(tokenizer.tokens[0].string).to eq "0o775"
        expect(tokenizer.tokens[0].value).to eq 7*8**2 + 7*8 + 5
      end
    end

    context "hexadecimal" do
      it "parses correctly" do
        tokenizer = described_class.new("0x1fA")
        expect(tokenizer.tokens.map(&:class)).to match_array([Keisan::Tokens::Number])
        expect(tokenizer.tokens[0].string).to eq "0x1fA"
        expect(tokenizer.tokens[0].value).to eq 256 + 15*16 + 10
      end
    end

    context "floating point" do
      it "gets floating point numbers correctly" do
        tokenizer = described_class.new("56.09")

        expect(tokenizer.tokens.map(&:class)).to match_array([
          Keisan::Tokens::Number
        ])

        expect(tokenizer.tokens[0].string).to eq "56.09"
        expect(tokenizer.tokens[0].value).to be_a Float
        expect(tokenizer.tokens[0].value).to eq 56.09
      end
    end

    context "scientific notation" do
      context "negative exponent" do
        it "gets scientific notation numbers correctly" do
          tokenizer = described_class.new("6.001e-3")

          expect(tokenizer.tokens.map(&:class)).to match_array([
            Keisan::Tokens::Number
          ])

          expect(tokenizer.tokens[0].string).to eq "6.001e-3"
          expect(tokenizer.tokens[0].value).to be_a Float
          expect(tokenizer.tokens[0].value).to eq 0.006001
        end
      end

      context "positive exponent" do
        it "gets scientific notation numbers correctly" do
          tokenizer = described_class.new("1234e2")

          expect(tokenizer.tokens.map(&:class)).to match_array([
            Keisan::Tokens::Number
          ])

          expect(tokenizer.tokens[0].string).to eq "1234e2"
          expect(tokenizer.tokens[0].value).to be_a Float
          expect(tokenizer.tokens[0].value).to eq 123400.0
        end
      end
    end
  end

  context "variables" do
    it "gets variables correctly" do
      tokenizer = described_class.new("x + 2*y_a1")

      expect(tokenizer.tokens.map(&:class)).to match_array([
        Keisan::Tokens::Word,
        Keisan::Tokens::ArithmeticOperator,
        Keisan::Tokens::Number,
        Keisan::Tokens::ArithmeticOperator,
        Keisan::Tokens::Word
      ])

      expect(tokenizer.tokens[0].string).to eq "x"
      expect(tokenizer.tokens[4].string).to eq "y_a1"
    end
  end

  context "simple operators" do
    it "picks out operators correctly" do
      tokenizer = described_class.new("-1+2-3*-4/5**6")

      expect(tokenizer.tokens.map(&:class)).to match_array([
        Keisan::Tokens::ArithmeticOperator,
        Keisan::Tokens::Number,
        Keisan::Tokens::ArithmeticOperator,
        Keisan::Tokens::Number,
        Keisan::Tokens::ArithmeticOperator,
        Keisan::Tokens::Number,
        Keisan::Tokens::ArithmeticOperator,
        Keisan::Tokens::ArithmeticOperator,
        Keisan::Tokens::Number,
        Keisan::Tokens::ArithmeticOperator,
        Keisan::Tokens::Number,
        Keisan::Tokens::ArithmeticOperator,
        Keisan::Tokens::Number
      ])

      expect(tokenizer.tokens[0].string).to eq "-"
      expect(tokenizer.tokens[2].string).to eq "+"
      expect(tokenizer.tokens[4].string).to eq "-"
      expect(tokenizer.tokens[6].string).to eq "*"
      expect(tokenizer.tokens[7].string).to eq "-"
      expect(tokenizer.tokens[9].string).to eq "/"
      expect(tokenizer.tokens[11].string).to eq "**"
    end
  end

  context "commas" do
    it "picks out commas" do
      tokenizer = described_class.new("2, 3, 5, 8")

      expect(tokenizer.tokens.map(&:class)).to match_array([
        Keisan::Tokens::Number,
        Keisan::Tokens::Comma,
        Keisan::Tokens::Number,
        Keisan::Tokens::Comma,
        Keisan::Tokens::Number,
        Keisan::Tokens::Comma,
        Keisan::Tokens::Number
      ])

      expect(tokenizer.tokens[1].string).to eq ","
      expect(tokenizer.tokens[3].string).to eq ","
      expect(tokenizer.tokens[5].string).to eq ","
    end
  end

  context "nested groups" do
    context "empty group" do
      it "has no sub tokens" do
        tokenizer = described_class.new("()")
        expect(tokenizer.tokens.count).to eq 1
        token = tokenizer.tokens.first
        expect(token).to be_a(Keisan::Tokens::Group)
        expect(token.string).to eq "()"
        expect(token.sub_tokens).to match_array([])
      end
    end

    context "mixed braces" do
      it "works as expected" do
        tokenizer = described_class.new("1+(x-[3+4]+5)-[6,7](8)")

        expect(tokenizer.tokens.map(&:class)).to match_array([
          Keisan::Tokens::Number,
          Keisan::Tokens::ArithmeticOperator,
          Keisan::Tokens::Group,
          Keisan::Tokens::ArithmeticOperator,
          Keisan::Tokens::Group,
          Keisan::Tokens::Group
        ])

        expect(tokenizer.tokens[0].value).to eq 1
        expect(tokenizer.tokens[1].operator_type).to eq :+
        expect(tokenizer.tokens[2].string).to eq "(x-[3+4]+5)"
        expect(tokenizer.tokens[3].operator_type).to eq :-
        expect(tokenizer.tokens[4].string).to eq "[6,7]"
        expect(tokenizer.tokens[5].string).to eq "(8)"

        group = tokenizer.tokens[2]
        expect(group.sub_tokens.map(&:class)).to match_array([
          Keisan::Tokens::Word,
          Keisan::Tokens::ArithmeticOperator,
          Keisan::Tokens::Group,
          Keisan::Tokens::ArithmeticOperator,
          Keisan::Tokens::Number
        ])

        expect(group.sub_tokens[0].string).to eq "x"
        expect(group.sub_tokens[1].operator_type).to eq :-
        expect(group.sub_tokens[2].string).to eq "[3+4]"
        expect(group.sub_tokens[3].operator_type).to eq :+
        expect(group.sub_tokens[4].value).to eq 5

        group = tokenizer.tokens[4]
        expect(group.sub_tokens.map(&:class)).to match_array([
          Keisan::Tokens::Number,
          Keisan::Tokens::Comma,
          Keisan::Tokens::Number
        ])

        expect(group.sub_tokens[0].value).to eq 6
        expect(group.sub_tokens[1].string).to eq ","
        expect(group.sub_tokens[2].value).to eq 7

        group = tokenizer.tokens[5]
        expect(group.sub_tokens.map(&:class)).to match_array([
          Keisan::Tokens::Number
        ])
        expect(group.sub_tokens[0].value).to eq 8
      end
    end

    it "handles #hashtags in strings" do
      tokenizer = described_class.new("1 - 2 # Comm'ent\nx + '#math' # Anot'her comment")

      expect(tokenizer.tokens.map(&:class)).to match_array([
        Keisan::Tokens::Number,
        Keisan::Tokens::ArithmeticOperator,
        Keisan::Tokens::Number,
        Keisan::Tokens::LineSeparator,
        Keisan::Tokens::Word,
        Keisan::Tokens::ArithmeticOperator,
        Keisan::Tokens::String
      ])

      expect(tokenizer.tokens.map(&:string)).to match_array([
        "1",
        "-",
        "2",
        "\n",
        "x",
        "+",
        "'#math'"
      ])
    end

    it "has nested groups properly tokenized" do
      tokenizer = described_class.new("'1'+'2'+(']]') + (('3') + '4')")

      expect(tokenizer.tokens.map(&:class)).to match_array([
        Keisan::Tokens::String,
        Keisan::Tokens::ArithmeticOperator,
        Keisan::Tokens::String,
        Keisan::Tokens::ArithmeticOperator,
        Keisan::Tokens::Group,
        Keisan::Tokens::ArithmeticOperator,
        Keisan::Tokens::Group
      ])

      group = tokenizer.tokens[4]
      expect(group.string).to eq "(']]')"
      expect(group.sub_tokens.map(&:class)).to match_array([Keisan::Tokens::String])

      group = tokenizer.tokens[6]
      expect(group.string).to eq "(('3') + '4')"
      expect(group.sub_tokens.map(&:class)).to match_array([
        Keisan::Tokens::Group,
        Keisan::Tokens::ArithmeticOperator,
        Keisan::Tokens::String
      ])
    end

    it "has nested groups properly tokenized" do
      tokenizer = described_class.new("1+(2+(3+4)+5)+(6)")

      expect(tokenizer.tokens.map(&:class)).to match_array([
        Keisan::Tokens::Number,
        Keisan::Tokens::ArithmeticOperator,
        Keisan::Tokens::Group,
        Keisan::Tokens::ArithmeticOperator,
        Keisan::Tokens::Group
      ])

      group = tokenizer.tokens[2]
      expect(group.string).to eq "(2+(3+4)+5)"

      expect(group.sub_tokens.map(&:class)).to match_array([
        Keisan::Tokens::Number,
        Keisan::Tokens::ArithmeticOperator,
        Keisan::Tokens::Group,
        Keisan::Tokens::ArithmeticOperator,
        Keisan::Tokens::Number
      ])

      group = group.sub_tokens[2]
      expect(group.string).to eq "(3+4)"

      expect(group.sub_tokens.map(&:class)).to match_array([
        Keisan::Tokens::Number,
        Keisan::Tokens::ArithmeticOperator,
        Keisan::Tokens::Number
      ])

      group = tokenizer.tokens[4]
      expect(group.string).to eq "(6)"
    end

    it "handles non nested groups properly" do
      tokenizer = described_class.new("(1+2)*(3+4)")

      expect(tokenizer.tokens.map(&:class)).to match_array([
        Keisan::Tokens::Group,
        Keisan::Tokens::ArithmeticOperator,
        Keisan::Tokens::Group
      ])

      expect(tokenizer.tokens[0].string).to eq "(1+2)"
      expect(tokenizer.tokens[1].string).to eq "*"
      expect(tokenizer.tokens[2].string).to eq "(3+4)"
    end

    it "handles strings with escaped characters inside parentheses" do
      tokenizer = described_class.new(%q{("\"foo")})
      expect(tokenizer.tokens.map(&:class)).to match_array([
        Keisan::Tokens::Group,
      ])
      expect(tokenizer.tokens[0].sub_tokens.map(&:class)).to match_array([
        Keisan::Tokens::String,
      ])
      expect(tokenizer.tokens[0].sub_tokens[0].value).to eq '"foo'

      tokenizer = described_class.new('("\"a\"()\"")')
      expect(tokenizer.tokens[0].sub_tokens[0].value).to eq '"a"()"'
    end
  end

  context "logical operators" do
    it "handles equal and not-equal operators" do
      tokenizer = described_class.new("50 == 30 + 20")

      expect(tokenizer.tokens.map(&:class)).to match_array([
        Keisan::Tokens::Number,
        Keisan::Tokens::LogicalOperator,
        Keisan::Tokens::Number,
        Keisan::Tokens::ArithmeticOperator,
        Keisan::Tokens::Number
      ])

      expect(tokenizer.tokens[0].value).to eq 50
      expect(tokenizer.tokens[1].operator_type).to eq :"=="
      expect(tokenizer.tokens[2].value).to eq 30
      expect(tokenizer.tokens[3].operator_type).to eq :+
      expect(tokenizer.tokens[4].value).to eq 20
    end

    it "gets correct operators" do
      tokenizer = described_class.new("!false || true && (1<2)")

      expect(tokenizer.tokens.map(&:class)).to match_array([
        Keisan::Tokens::LogicalOperator,
        Keisan::Tokens::Boolean,
        Keisan::Tokens::LogicalOperator,
        Keisan::Tokens::Boolean,
        Keisan::Tokens::LogicalOperator,
        Keisan::Tokens::Group
      ])

      expect(tokenizer.tokens[0].operator_type).to eq :"!"
      expect(tokenizer.tokens[1].string).to eq "false"
      expect(tokenizer.tokens[2].operator_type).to eq :"||"
      expect(tokenizer.tokens[3].string).to eq "true"
      expect(tokenizer.tokens[4].operator_type).to eq :"&&"
      expect(tokenizer.tokens[5].string).to eq "(1<2)"

      group = tokenizer.tokens[5]

      expect(group.sub_tokens.map(&:class)).to match_array([
        Keisan::Tokens::Number,
        Keisan::Tokens::LogicalOperator,
        Keisan::Tokens::Number
      ])

      expect(group.sub_tokens[0].string).to eq "1"
      expect(group.sub_tokens[1].operator_type).to eq :"<"
      expect(group.sub_tokens[2].string).to eq "2"
    end
  end

  context "bitwise operators" do
    it "understands bitwise and, or, xor, not" do
      tokenizer = described_class.new("~x ^ (7|2) & 4")

      expect(tokenizer.tokens.map(&:class)).to match_array([
        Keisan::Tokens::BitwiseOperator,
        Keisan::Tokens::Word,
        Keisan::Tokens::BitwiseOperator,
        Keisan::Tokens::Group,
        Keisan::Tokens::BitwiseOperator,
        Keisan::Tokens::Number
      ])

      expect(tokenizer.tokens[0].operator_type).to eq :"~"
      expect(tokenizer.tokens[1].string).to eq "x"
      expect(tokenizer.tokens[2].operator_type).to eq :"^"
      expect(tokenizer.tokens[3].string).to eq "(7|2)"
      expect(tokenizer.tokens[4].operator_type).to eq :"&"
      expect(tokenizer.tokens[5].string).to eq "4"

      group = tokenizer.tokens[3]

      expect(group.sub_tokens.map(&:class)).to match_array([
        Keisan::Tokens::Number,
        Keisan::Tokens::BitwiseOperator,
        Keisan::Tokens::Number
      ])

      expect(group.sub_tokens[0].string).to eq "7"
      expect(group.sub_tokens[1].operator_type).to eq :"|"
      expect(group.sub_tokens[2].string).to eq "2"
    end

    it "understands bitwise shift operators" do
      tokenizer = described_class.new("(x << 2) >> 1")

      expect(tokenizer.tokens.map(&:class)).to match_array([
        Keisan::Tokens::Group,
        Keisan::Tokens::BitwiseShift,
        Keisan::Tokens::Number
      ])

      expect(tokenizer.tokens[0].string).to eq "(x << 2)"
      expect(tokenizer.tokens[1].operator_type).to eq :>>
      expect(tokenizer.tokens[2].string).to eq "1"

      group = tokenizer.tokens[0]

      expect(group.sub_tokens.map(&:class)).to match_array([
        Keisan::Tokens::Word,
        Keisan::Tokens::BitwiseShift,
        Keisan::Tokens::Number
      ])

      expect(group.sub_tokens[0].string).to eq "x"
      expect(group.sub_tokens[1].operator_type).to eq :<<
      expect(group.sub_tokens[2].string).to eq "2"
    end
  end

  context "strings" do
    it "has correct parsing" do
      tokenizer = described_class.new("'hello world' + \" foo bar \"")

      expect(tokenizer.tokens.map(&:class)).to match_array([
        Keisan::Tokens::String,
        Keisan::Tokens::ArithmeticOperator,
        Keisan::Tokens::String
      ])

      expect(tokenizer.tokens[0].string).to eq "'hello world'"
      expect(tokenizer.tokens[0].value).to eq "hello world"
      expect(tokenizer.tokens[1].string).to eq "+"
      expect(tokenizer.tokens[2].string).to eq '" foo bar "'
      expect(tokenizer.tokens[2].value).to eq " foo bar "
    end
  end

  context "curly braces" do
    it "matches as a group" do
      tokenizer = described_class.new("x = {y;4}")

      expect(tokenizer.tokens.map(&:class)).to match_array([
        Keisan::Tokens::Word,
        Keisan::Tokens::Assignment,
        Keisan::Tokens::Group
      ])

      group = tokenizer.tokens[-1]
      expect(group.group_type).to eq :curly

      expect(group.sub_tokens.map(&:class)).to eq([
        Keisan::Tokens::Word,
        Keisan::Tokens::LineSeparator,
        Keisan::Tokens::Number
      ])
    end
  end

  context "dot operator" do
    it "parses correctly" do
      tokenizer = described_class.new("[1,2,3].size()")

      expect(tokenizer.tokens.map(&:class)).to match_array([
        Keisan::Tokens::Group,
        Keisan::Tokens::Dot,
        Keisan::Tokens::Word,
        Keisan::Tokens::Group
      ])

      group = tokenizer.tokens[0]
      expect(group.string).to eq "[1,2,3]"
      expect(group.group_type).to eq :square
      expect(group.sub_tokens.map(&:class)).to match_array([
        Keisan::Tokens::Number,
        Keisan::Tokens::Comma,
        Keisan::Tokens::Number,
        Keisan::Tokens::Comma,
        Keisan::Tokens::Number
      ])
      expect(group.sub_tokens[0].value).to eq 1
      expect(group.sub_tokens[2].value).to eq 2
      expect(group.sub_tokens[4].value).to eq 3

      expect(tokenizer.tokens[2].string).to eq "size"

      group = tokenizer.tokens[3]
      expect(group.sub_tokens).to be_empty
    end
  end

  context "assignment" do
    it "parses correctly" do
      tokenizer = described_class.new("x = y = 5")

      expect(tokenizer.tokens.map(&:class)).to eq([
        Keisan::Tokens::Word,
        Keisan::Tokens::Assignment,
        Keisan::Tokens::Word,
        Keisan::Tokens::Assignment,
        Keisan::Tokens::Number
      ])

      expect(tokenizer.tokens[0].string).to eq "x"
      expect(tokenizer.tokens[2].string).to eq "y"
      expect(tokenizer.tokens[4].value).to eq 5
    end

    it "parses compound assignment" do
      tokenizer = described_class.new("i >>= 1")

      expect(tokenizer.tokens.map(&:class)).to eq([
        Keisan::Tokens::Word,
        Keisan::Tokens::Assignment,
        Keisan::Tokens::Number
      ])

      expect(tokenizer.tokens[0].string).to eq "i"
      expect(tokenizer.tokens[1].string).to eq ">>="
      expect(tokenizer.tokens[2].string).to eq "1"
    end
  end

  context "multiline" do
    it "parses correctly" do
      tokenizer = described_class.new("1 \n x; 3 ")

      expect(tokenizer.tokens.map(&:class)).to eq([
        Keisan::Tokens::Number,
        Keisan::Tokens::LineSeparator,
        Keisan::Tokens::Word,
        Keisan::Tokens::LineSeparator,
        Keisan::Tokens::Number
      ])

      expect(tokenizer.tokens[0].value).to eq 1
      expect(tokenizer.tokens[2].string).to eq "x"
      expect(tokenizer.tokens[4].value).to eq 3
    end
  end

  context "function call" do
    it "parses correctly" do
      tokenizer = described_class.new("foo bar 11, 22")

      expect(tokenizer.tokens.map(&:class)).to eq([
        Keisan::Tokens::Word,
        Keisan::Tokens::Word,
        Keisan::Tokens::Number,
        Keisan::Tokens::Comma,
        Keisan::Tokens::Number
      ])
    end
  end

  context "hash definition" do
    it "parses correctly" do
      tokenizer = described_class.new("{'foo': 'bar'}")

      expect(tokenizer.tokens.map(&:class)).to eq([
        Keisan::Tokens::Group
      ])
      expect(tokenizer.tokens.first.sub_tokens.map(&:class)).to eq([
        Keisan::Tokens::String,
        Keisan::Tokens::Colon,
        Keisan::Tokens::String
      ])
    end
  end
end

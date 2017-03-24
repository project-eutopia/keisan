require "spec_helper"

RSpec.describe Compute::Tokenizer do
  context "invalid symbols" do
    it "raises a TokenizingError" do
      expect { described_class.new("2%3") }.to raise_error(Compute::Exceptions::TokenizingError)
    end
  end

  context "numbers" do
    context "integer" do
      it "gets integers correctly" do
        tokenizer = described_class.new("-2")

        expect(tokenizer.tokens.map(&:class)).to match_array([
          Compute::Tokens::ArithmeticOperator,
          Compute::Tokens::Number
        ])

        expect(tokenizer.tokens[0].string).to eq "-"
        expect(tokenizer.tokens[1].string).to eq "2"
        expect(tokenizer.tokens[1].value).to be_a Integer
        expect(tokenizer.tokens[1].value).to eq 2
      end
    end

    context "floating point" do
      it "gets floating point numbers correctly" do
        tokenizer = described_class.new("56.09")

        expect(tokenizer.tokens.map(&:class)).to match_array([
          Compute::Tokens::Number
        ])

        expect(tokenizer.tokens[0].string).to eq "56.09"
        expect(tokenizer.tokens[0].value).to be_a Float
        expect(tokenizer.tokens[0].value).to eq 56.09
      end
    end

    context "scientific notation" do
      it "gets scientific notation numbers correctly" do
        tokenizer = described_class.new("6.001e-3")

        expect(tokenizer.tokens.map(&:class)).to match_array([
          Compute::Tokens::Number
        ])

        expect(tokenizer.tokens[0].string).to eq "6.001e-3"
        expect(tokenizer.tokens[0].value).to be_a Float
        expect(tokenizer.tokens[0].value).to eq 0.006001
      end
    end
  end

  context "variables" do
    it "gets variables correctly" do
      tokenizer = described_class.new("x + 2*y_a1")

      expect(tokenizer.tokens.map(&:class)).to match_array([
        Compute::Tokens::Word,
        Compute::Tokens::ArithmeticOperator,
        Compute::Tokens::Number,
        Compute::Tokens::ArithmeticOperator,
        Compute::Tokens::Word
      ])

      expect(tokenizer.tokens[0].string).to eq "x"
      expect(tokenizer.tokens[4].string).to eq "y_a1"
    end
  end

  context "simple operators" do
    it "picks out operators correctly" do
      tokenizer = described_class.new("-1+2-3*-4/5**6")

      expect(tokenizer.tokens.map(&:class)).to match_array([
        Compute::Tokens::ArithmeticOperator,
        Compute::Tokens::Number,
        Compute::Tokens::ArithmeticOperator,
        Compute::Tokens::Number,
        Compute::Tokens::ArithmeticOperator,
        Compute::Tokens::Number,
        Compute::Tokens::ArithmeticOperator,
        Compute::Tokens::ArithmeticOperator,
        Compute::Tokens::Number,
        Compute::Tokens::ArithmeticOperator,
        Compute::Tokens::Number,
        Compute::Tokens::ArithmeticOperator,
        Compute::Tokens::Number
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
        Compute::Tokens::Number,
        Compute::Tokens::Comma,
        Compute::Tokens::Number,
        Compute::Tokens::Comma,
        Compute::Tokens::Number,
        Compute::Tokens::Comma,
        Compute::Tokens::Number
      ])

      expect(tokenizer.tokens[1].string).to eq ","
      expect(tokenizer.tokens[3].string).to eq ","
      expect(tokenizer.tokens[5].string).to eq ","
    end
  end

  context "nested groups" do
    context "empty group" do
      it "has no sub tokens" do
        tokenizer = described_class.new("(  )")
        expect(tokenizer.tokens.count).to eq 1
        token = tokenizer.tokens.first
        expect(token).to be_a(Compute::Tokens::Group)
        expect(token.string).to eq "()"
        expect(token.sub_tokens).to match_array([])
      end
    end

    context "mixed braces" do
      it "works as expected" do
        tokenizer = described_class.new("1 + (x - [ 3+4 ] + 5) - [6,7](8)")

        expect(tokenizer.tokens.map(&:class)).to match_array([
          Compute::Tokens::Number,
          Compute::Tokens::ArithmeticOperator,
          Compute::Tokens::Group,
          Compute::Tokens::ArithmeticOperator,
          Compute::Tokens::Group,
          Compute::Tokens::Group
        ])

        expect(tokenizer.tokens[0].value).to eq 1
        expect(tokenizer.tokens[1].operator_type).to eq :+
        expect(tokenizer.tokens[2].string).to eq "(x-[3+4]+5)"
        expect(tokenizer.tokens[3].operator_type).to eq :-
        expect(tokenizer.tokens[4].string).to eq "[6,7]"
        expect(tokenizer.tokens[5].string).to eq "(8)"

        group = tokenizer.tokens[2]
        expect(group.sub_tokens.map(&:class)).to match_array([
          Compute::Tokens::Word,
          Compute::Tokens::ArithmeticOperator,
          Compute::Tokens::Group,
          Compute::Tokens::ArithmeticOperator,
          Compute::Tokens::Number
        ])

        expect(group.sub_tokens[0].string).to eq "x"
        expect(group.sub_tokens[1].operator_type).to eq :-
        expect(group.sub_tokens[2].string).to eq "[3+4]"
        expect(group.sub_tokens[3].operator_type).to eq :+
        expect(group.sub_tokens[4].value).to eq 5

        group = tokenizer.tokens[4]
        expect(group.sub_tokens.map(&:class)).to match_array([
          Compute::Tokens::Number,
          Compute::Tokens::Comma,
          Compute::Tokens::Number
        ])

        expect(group.sub_tokens[0].value).to eq 6
        expect(group.sub_tokens[1].string).to eq ","
        expect(group.sub_tokens[2].value).to eq 7

        group = tokenizer.tokens[5]
        expect(group.sub_tokens.map(&:class)).to match_array([
          Compute::Tokens::Number
        ])
        expect(group.sub_tokens[0].value).to eq 8
      end
    end

    it "has nested groups properly tokenized" do
      tokenizer = described_class.new("1 + (2 + (3+4) + 5) + (6)")

      expect(tokenizer.tokens.map(&:class)).to match_array([
        Compute::Tokens::Number,
        Compute::Tokens::ArithmeticOperator,
        Compute::Tokens::Group,
        Compute::Tokens::ArithmeticOperator,
        Compute::Tokens::Group
      ])

      group = tokenizer.tokens[2]
      expect(group.string).to eq "(2+(3+4)+5)"

      expect(group.sub_tokens.map(&:class)).to match_array([
        Compute::Tokens::Number,
        Compute::Tokens::ArithmeticOperator,
        Compute::Tokens::Group,
        Compute::Tokens::ArithmeticOperator,
        Compute::Tokens::Number
      ])

      group = group.sub_tokens[2]
      expect(group.string).to eq "(3+4)"

      expect(group.sub_tokens.map(&:class)).to match_array([
        Compute::Tokens::Number,
        Compute::Tokens::ArithmeticOperator,
        Compute::Tokens::Number
      ])

      group = tokenizer.tokens[4]
      expect(group.string).to eq "(6)"
    end

    it "handles non nested groups properly" do
      tokenizer = described_class.new("(1 + 2) * (3 + 4)")

      expect(tokenizer.tokens.map(&:class)).to match_array([
        Compute::Tokens::Group,
        Compute::Tokens::ArithmeticOperator,
        Compute::Tokens::Group
      ])

      expect(tokenizer.tokens[0].string).to eq "(1+2)"
      expect(tokenizer.tokens[1].string).to eq "*"
      expect(tokenizer.tokens[2].string).to eq "(3+4)"
    end
  end

  context "logical operators" do
    it "gets correct operators" do
      tokenizer = described_class.new("!false || true && (1 < 2)")

      expect(tokenizer.tokens.map(&:class)).to match_array([
        Compute::Tokens::LogicalOperator,
        Compute::Tokens::Word,
        Compute::Tokens::LogicalOperator,
        Compute::Tokens::Word,
        Compute::Tokens::LogicalOperator,
        Compute::Tokens::Group
      ])

      expect(tokenizer.tokens[0].operator_type).to eq :"!"
      expect(tokenizer.tokens[1].string).to eq "false"
      expect(tokenizer.tokens[2].operator_type).to eq :"||"
      expect(tokenizer.tokens[3].string).to eq "true"
      expect(tokenizer.tokens[4].operator_type).to eq :"&&"
      expect(tokenizer.tokens[5].string).to eq "(1<2)"

      group = tokenizer.tokens[5]

      expect(group.sub_tokens.map(&:class)).to match_array([
        Compute::Tokens::Number,
        Compute::Tokens::LogicalOperator,
        Compute::Tokens::Number
      ])

      expect(group.sub_tokens[0].string).to eq "1"
      expect(group.sub_tokens[1].operator_type).to eq :"<"
      expect(group.sub_tokens[2].string).to eq "2"
    end
  end

  context "bitwise operators" do
    it "gets correct operators" do
      tokenizer = described_class.new("~x ^ (7 | 2) & 4")

      expect(tokenizer.tokens.map(&:class)).to match_array([
        Compute::Tokens::BitwiseOperator,
        Compute::Tokens::Word,
        Compute::Tokens::BitwiseOperator,
        Compute::Tokens::Group,
        Compute::Tokens::BitwiseOperator,
        Compute::Tokens::Number
      ])

      expect(tokenizer.tokens[0].operator_type).to eq :"~"
      expect(tokenizer.tokens[1].string).to eq "x"
      expect(tokenizer.tokens[2].operator_type).to eq :"^"
      expect(tokenizer.tokens[3].string).to eq "(7|2)"
      expect(tokenizer.tokens[4].operator_type).to eq :"&"
      expect(tokenizer.tokens[5].string).to eq "4"

      group = tokenizer.tokens[3]

      expect(group.sub_tokens.map(&:class)).to match_array([
        Compute::Tokens::Number,
        Compute::Tokens::BitwiseOperator,
        Compute::Tokens::Number
      ])

      expect(group.sub_tokens[0].string).to eq "7"
      expect(group.sub_tokens[1].operator_type).to eq :"|"
      expect(group.sub_tokens[2].string).to eq "2"
    end
  end

  context "strings" do
    it "has correct parsing" do
      tokenizer = described_class.new("'hello world' + \" foo bar \"")

      expect(tokenizer.tokens.map(&:class)).to match_array([
        Compute::Tokens::String,
        Compute::Tokens::ArithmeticOperator,
        Compute::Tokens::String
      ])

      expect(tokenizer.tokens[0].string).to eq "'hello world'"
      expect(tokenizer.tokens[0].value).to eq "hello world"
      expect(tokenizer.tokens[1].string).to eq "+"
      expect(tokenizer.tokens[2].string).to eq '" foo bar "'
      expect(tokenizer.tokens[2].value).to eq " foo bar "
    end
  end
end

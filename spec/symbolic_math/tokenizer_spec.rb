require "spec_helper"

RSpec.describe SymbolicMath::Tokenizer do
  context "numbers" do
    context "integer" do
      it "gets integers correctly" do
        tokenizer = described_class.new("-2")

        expect(tokenizer.tokens.map(&:class)).to match_array([
          SymbolicMath::Tokens::Operator,
          SymbolicMath::Tokens::Number
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
          SymbolicMath::Tokens::Number
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
          SymbolicMath::Tokens::Number
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
        SymbolicMath::Tokens::Word,
        SymbolicMath::Tokens::Operator,
        SymbolicMath::Tokens::Number,
        SymbolicMath::Tokens::Operator,
        SymbolicMath::Tokens::Word
      ])

      expect(tokenizer.tokens[0].string).to eq "x"
      expect(tokenizer.tokens[4].string).to eq "y_a1"
    end
  end

  context "simple operators" do
    it "picks out operators correctly" do
      tokenizer = described_class.new("-1+2-3*-4/5**6")

      expect(tokenizer.tokens.map(&:class)).to match_array([
        SymbolicMath::Tokens::Operator,
        SymbolicMath::Tokens::Number,
        SymbolicMath::Tokens::Operator,
        SymbolicMath::Tokens::Number,
        SymbolicMath::Tokens::Operator,
        SymbolicMath::Tokens::Number,
        SymbolicMath::Tokens::Operator,
        SymbolicMath::Tokens::Operator,
        SymbolicMath::Tokens::Number,
        SymbolicMath::Tokens::Operator,
        SymbolicMath::Tokens::Number,
        SymbolicMath::Tokens::Operator,
        SymbolicMath::Tokens::Number
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
        SymbolicMath::Tokens::Number,
        SymbolicMath::Tokens::Comma,
        SymbolicMath::Tokens::Number,
        SymbolicMath::Tokens::Comma,
        SymbolicMath::Tokens::Number,
        SymbolicMath::Tokens::Comma,
        SymbolicMath::Tokens::Number
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
        expect(token).to be_a(SymbolicMath::Tokens::Group)
        expect(token.string).to eq "()"
        expect(token.sub_tokens).to match_array([])
      end
    end

    it "has nested groups properly tokenized" do
      tokenizer = described_class.new("1 + (2 + (3+4) + 5)")

      expect(tokenizer.tokens.map(&:class)).to match_array([
        SymbolicMath::Tokens::Number,
        SymbolicMath::Tokens::Operator,
        SymbolicMath::Tokens::Group
      ])

      group = tokenizer.tokens.last
      expect(group.string).to eq "(2+(3+4)+5)"

      expect(group.sub_tokens.map(&:class)).to match_array([
        SymbolicMath::Tokens::Number,
        SymbolicMath::Tokens::Operator,
        SymbolicMath::Tokens::Group,
        SymbolicMath::Tokens::Operator,
        SymbolicMath::Tokens::Number
      ])

      group = group.sub_tokens[2]
      expect(group.string).to eq "(3+4)"

      expect(group.sub_tokens.map(&:class)).to match_array([
        SymbolicMath::Tokens::Number,
        SymbolicMath::Tokens::Operator,
        SymbolicMath::Tokens::Number
      ])
    end

    it "handles non nested groups properly" do
      tokenizer = described_class.new("(1 + 2) * (3 + 4)")

      expect(tokenizer.tokens.map(&:class)).to match_array([
        SymbolicMath::Tokens::Group,
        SymbolicMath::Tokens::Operator,
        SymbolicMath::Tokens::Group
      ])

      expect(tokenizer.tokens[0].string).to eq "(1+2)"
      expect(tokenizer.tokens[1].string).to eq "*"
      expect(tokenizer.tokens[2].string).to eq "(3+4)"
    end
  end
end

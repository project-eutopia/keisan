require "spec_helper"

RSpec.describe Keisan::StringAndGroupParser do
  describe described_class::OtherPortion do
    it "cannot start with a quote or brace character" do
      expect { described_class.new("''", 0) }.to raise_error Keisan::Exceptions::TokenizingError
      expect { described_class.new("(", 0) }.to raise_error Keisan::Exceptions::TokenizingError
      expect { described_class.new(")", 0) }.to raise_error Keisan::Exceptions::TokenizingError
    end

    it "consumes characters up to a quote or opening brace character" do
      parser = described_class.new("1 + ''", 0)
      expect(parser.end_index).to eq 4
      expect(parser.string).to eq ("1 + ")

      parser = described_class.new("1 + ()", 0)
      expect(parser.end_index).to eq 4
      expect(parser.string).to eq ("1 + ")

      parser = described_class.new("'' + 1", 2)
      expect(parser.end_index).to eq 6
      expect(parser.string).to eq (" + 1")
    end
  end

  describe described_class::StringPortion do
    it "works on strings at different positions" do
      parser = described_class.new("''", 0)
      expect(parser.start_index).to eq 0
      expect(parser.end_index).to eq 2
      expect(parser.string).to eq "''"

      parser = described_class.new("'hello'", 0)
      expect(parser.start_index).to eq 0
      expect(parser.end_index).to eq 7
      expect(parser.string).to eq "'hello'"

      parser = described_class.new("'hello' + 1", 0)
      expect(parser.start_index).to eq 0
      expect(parser.end_index).to eq 7
      expect(parser.string).to eq "'hello'"

      parser = described_class.new("1 + 'hello'", 4)
      expect(parser.start_index).to eq 4
      expect(parser.end_index).to eq 11
      expect(parser.string).to eq "'hello'"

      parser = described_class.new("1 + 'hello' + 2", 4)
      expect(parser.start_index).to eq 4
      expect(parser.end_index).to eq 11
      expect(parser.string).to eq "'hello'"
    end

    it "handles escape characters" do
      parser = described_class.new("1 + 'a\\\\\\a\\b\\r\\n\\s\\tb' + 2", 4)
      expect(parser.start_index).to eq 4
      expect(parser.end_index).to eq 22
      expect(parser.string).to eq "'a\\\a\b\r\n\s\tb'"
    end

    it "handles escape quotes" do
      parser = described_class.new("\"\\'hello\"", 0)
      expect(parser.start_index).to eq 0
      expect(parser.end_index).to eq 9
      expect(parser.string).to eq "\"'hello\""
    end

    it "can have braces" do
      parser = described_class.new("1 + \"a()b\" + 2", 4)
      expect(parser.start_index).to eq 4
      expect(parser.end_index).to eq 10
      expect(parser.string).to eq '"a()b"'
    end

    it "fails with single quote" do
      expect { described_class.new("'", 0) }.to raise_error Keisan::Exceptions::TokenizingError
    end

    it "fails on incorrect start_index" do
      expect { described_class.new("1 + \"hello\"", 0) }.to raise_error Keisan::Exceptions::TokenizingError
    end

    it "fails when no closing quote found" do
      expect { described_class.new("\"hello'", 0) }.to raise_error Keisan::Exceptions::TokenizingError
    end

    it "fails on unknown escape character" do
      expect { described_class.new("'as\\cdf'", 0) }.to raise_error Keisan::Exceptions::TokenizingError
    end

    it "fails on escape character at end" do
      expect { described_class.new("'as\\", 0) }.to raise_error Keisan::Exceptions::TokenizingError
    end
  end

  describe described_class::GroupPortion do
    it "must start and end with opening and closing braces" do
      expect { described_class.new("x", 0) }.to raise_error Keisan::Exceptions::TokenizingError
      expect { described_class.new("1", 0) }.to raise_error Keisan::Exceptions::TokenizingError
      expect { described_class.new("''", 0) }.to raise_error Keisan::Exceptions::TokenizingError
      expect { described_class.new("(", 0) }.to raise_error Keisan::Exceptions::TokenizingError
      expect { described_class.new("(]", 0) }.to raise_error Keisan::Exceptions::TokenizingError
    end

    it "parses the internal portions inside the braces" do
      parser = described_class.new("()", 0)
      expect(parser.portions).to match_array([])

      parser = described_class.new("(1 + '2' + [3])", 0)
      expect(parser.opening_brace).to eq "("
      expect(parser.closing_brace).to eq ")"
      expect(parser.portions.size).to eq 4
      expect(parser.portions[0]).to be_a(Keisan::StringAndGroupParser::OtherPortion)
      expect(parser.portions[0].to_s).to eq "1 + "
      expect(parser.portions[1]).to be_a(Keisan::StringAndGroupParser::StringPortion)
      expect(parser.portions[1].to_s).to eq "'2'"
      expect(parser.portions[2]).to be_a(Keisan::StringAndGroupParser::OtherPortion)
      expect(parser.portions[2].to_s).to eq " + "
      expect(parser.portions[3]).to be_a(Keisan::StringAndGroupParser::GroupPortion)
      expect(parser.portions[3].to_s).to eq "[3]"
    end
  end
end

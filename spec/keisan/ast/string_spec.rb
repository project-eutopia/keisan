require "spec_helper"

RSpec.describe Keisan::AST::String do
  describe "is_constant?" do
    it "is true" do
      expect(Keisan::AST::String.new('foo').is_constant?).to eq true
    end
  end

  describe "evaluate" do
    it "reduces to a single string when using plus to concatenate" do
      ast = Keisan::AST.parse("'hello ' + 'world'")
      expect(ast.evaluate).to be_a(described_class)
      expect(ast.evaluate.value).to eq "hello world"
    end

    it "works on strings with mixed quotes" do
      ast = Keisan::AST.parse("\"foo ' bar\"")
      expect(ast.evaluate).to be_a(described_class)
      expect(ast.evaluate.value).to eq "foo ' bar"
    end
  end

  describe "to_s" do
    it "prints with quotes" do
      ast = Keisan::AST.parse("\"foo ' bar\"")
      expect(ast.to_s).to eq "\"foo ' bar\""
    end
  end

  describe "addition" do
    context "when operating on string" do
      it "should reduce to a single string" do
        res = Keisan::AST::String.new("hello ") + Keisan::AST::String.new("world")
        expect(res).to be_a(described_class)
        expect(res.value).to eq "hello world"
      end
    end

    context "when operating on number" do
      it "should raise an error" do
        expect{Keisan::AST::String.new("hello ") + Keisan::AST::Number.new(1)}.to raise_error(Keisan::Exceptions::TypeError)
      end
    end
  end

  describe "simplify" do
    it "should concatenate strings if possible" do
      calculator = Keisan::Calculator.new
      result = calculator.simplify("'hello ' + 'world'")
      expect(result.to_s).to eq "\"hello world\""
    end
  end

  describe "logical operations" do
    it "can do == and != checks" do
      positive_equal     = described_class.new("a").equal     described_class.new("a")
      negative_equal     = described_class.new("a").equal     described_class.new("b")
      positive_not_equal = described_class.new("a").not_equal described_class.new("b")
      negative_not_equal = described_class.new("a").not_equal described_class.new("a")

      expect(positive_equal).to be_a(Keisan::AST::Boolean)
      expect(positive_equal.value).to eq true
      expect(negative_equal).to be_a(Keisan::AST::Boolean)
      expect(negative_equal.value).to eq false
      expect(positive_not_equal).to be_a(Keisan::AST::Boolean)
      expect(positive_not_equal.value).to eq true
      expect(negative_not_equal).to be_a(Keisan::AST::Boolean)
      expect(negative_not_equal.value).to eq false

      equal_other     = described_class.new("a").equal     Keisan::AST::Number.new(1)
      not_equal_other = described_class.new("a").not_equal Keisan::AST::Number.new(1)

      expect(equal_other).to be_a(Keisan::AST::Boolean)
      expect(equal_other.value).to eq false
      expect(not_equal_other).to be_a(Keisan::AST::Boolean)
      expect(not_equal_other.value).to eq true
    end
  end
end

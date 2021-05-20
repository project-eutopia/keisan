require "spec_helper"

RSpec.describe Keisan::AST::Boolean do
  describe "evaluate" do
    it "reduces to a single number when using arithmetic operators" do
      ast = Keisan::AST.parse("true && false")
      expect(ast.evaluate).to be_a(described_class)
      expect(ast.evaluate.value).to eq false
    end
  end

  describe "is_constant?" do
    it "is true" do
      expect(described_class.new(true).is_constant?).to eq true
    end
  end

  describe "operations" do
    it "should reduce to the answer right away" do
      res = !Keisan::AST::Boolean.new(true)
      expect(res).to be_a(described_class)
      expect(res.value).to eq false

      res = Keisan::AST::Boolean.new(true).and( Keisan::AST::Boolean.new(true) )
      expect(res).to be_a(described_class)
      expect(res.value).to eq true

      res = Keisan::AST::Boolean.new(false).or( Keisan::AST::Boolean.new(true) )
      expect(res).to be_a(described_class)
      expect(res.value).to eq true
    end
  end

  describe "logical operations" do
    it "can do && and || checks" do
      positive_and = described_class.new(true).and described_class.new(true)
      negative_and = described_class.new(true).and described_class.new(false)
      positive_or  = described_class.new(true).or  described_class.new(false)
      negative_or  = described_class.new(false).or described_class.new(false)

      expect(positive_and).to be_a(Keisan::AST::Boolean)
      expect(positive_and.value).to eq true
      expect(negative_and).to be_a(Keisan::AST::Boolean)
      expect(negative_and.value).to eq false
      expect(positive_or).to be_a(Keisan::AST::Boolean)
      expect(positive_or.value).to eq true
      expect(negative_or).to be_a(Keisan::AST::Boolean)
      expect(negative_or.value).to eq false

      and_other = described_class.new(true).and Keisan::AST::Number.new(1)
      or_other  = described_class.new(true).or  Keisan::AST::Number.new(1)

      expect(and_other).to be_a(Keisan::AST::LogicalAnd)
      expect(or_other).to be_a(Keisan::AST::LogicalOr)
    end

    it "can do == and != checks" do
      positive_equal     = described_class.new(true).equal     described_class.new(true)
      negative_equal     = described_class.new(true).equal     described_class.new(false)
      positive_not_equal = described_class.new(true).not_equal described_class.new(false)
      negative_not_equal = described_class.new(true).not_equal described_class.new(true)

      expect(positive_equal).to be_a(Keisan::AST::Boolean)
      expect(positive_equal.value).to eq true
      expect(negative_equal).to be_a(Keisan::AST::Boolean)
      expect(negative_equal.value).to eq false
      expect(positive_not_equal).to be_a(Keisan::AST::Boolean)
      expect(positive_not_equal.value).to eq true
      expect(negative_not_equal).to be_a(Keisan::AST::Boolean)
      expect(negative_not_equal.value).to eq false

      equal_other     = described_class.new(true).equal     Keisan::AST::Number.new(1)
      not_equal_other = described_class.new(true).not_equal Keisan::AST::Number.new(1)

      expect(equal_other).to be_a(Keisan::AST::LogicalEqual)
      expect(not_equal_other).to be_a(Keisan::AST::LogicalNotEqual)
    end
  end
end

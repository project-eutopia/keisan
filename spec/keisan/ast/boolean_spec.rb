require "spec_helper"

RSpec.describe Keisan::AST::Boolean do
  describe "evaluate" do
    it "reduces to a single number when using arithmetic operators" do
      ast = Keisan::AST.parse("true && false")
      expect(ast.evaluate).to be_a(described_class)
      expect(ast.evaluate.value).to eq false
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
end

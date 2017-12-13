require "spec_helper"

RSpec.describe Keisan::AST::String do
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

  describe "operations" do
    it "should reduce to a single string" do
      res = Keisan::AST::String.new("hello ") + Keisan::AST::String.new("world")
      expect(res).to be_a(described_class)
      expect(res.value).to eq "hello world"
    end
  end
end

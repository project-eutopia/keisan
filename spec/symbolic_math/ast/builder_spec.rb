require "spec_helper"

RSpec.describe SymbolicMath::AST::Builder do
  context "just simple operations" do
    it "correctly builds the AST" do
      ast = described_class.new(string: "1 + 2").ast
      expect(ast.value).to eq 3

      ast = described_class.new(string: "7.5 - 3").ast
      expect(ast.value).to eq 4.5

      ast = described_class.new(string: "2 + 3 * 5").ast
      expect(ast.value).to eq 17

      ast = described_class.new(string: "8 / 5").ast
      expect(ast.value).to eq Rational(8, 5)

      ast = described_class.new(string: "4**2 + 3 * 5").ast
      expect(ast.value).to eq 31

      ast = described_class.new(string: "2**(1/2)").ast
      expect(ast.value).to eq Math.sqrt(2)
    end
  end
end

require "spec_helper"

RSpec.describe Keisan::AST::Number do
  describe "evaluate" do
    it "reduces to a single number when using arithmetic operators" do
      ast = Keisan::AST.parse("1+2")
      expect(ast.evaluate).to be_a(described_class)
      expect(ast.evaluate.value).to eq 3

      ast = Keisan::AST.parse("15-4")
      expect(ast.evaluate).to be_a(described_class)
      expect(ast.evaluate.value).to eq 11

      ast = Keisan::AST.parse("2*3")
      expect(ast.evaluate).to be_a(described_class)
      expect(ast.evaluate.value).to eq 6

      ast = Keisan::AST.parse("1/7")
      expect(ast.evaluate).to be_a(described_class)
      expect(ast.evaluate.value).to eq Rational(1,7)

      ast = Keisan::AST.parse("22 % 5")
      expect(ast.evaluate).to be_a(described_class)
      expect(ast.evaluate.value).to eq 2

      ast = Keisan::AST.parse("3 ** 3 ** 3")
      expect(ast.evaluate).to be_a(described_class)
      expect(ast.evaluate.value).to eq 3**(3**3)

      ast = Keisan::AST.parse("(1+2) * (3+4)")
      expect(ast.evaluate).to be_a(described_class)
      expect(ast.evaluate.value).to eq 21

      ast = Keisan::AST.parse("+10")
      expect(ast.evaluate).to be_a(described_class)
      expect(ast.evaluate.value).to eq 10

      ast = Keisan::AST.parse("-12")
      expect(ast.evaluate).to be_a(described_class)
      expect(ast.evaluate.value).to eq -12

      ast = Keisan::AST.parse("~0")
      expect(ast.evaluate).to be_a(described_class)
      expect(ast.evaluate.value).to eq -1

      ast = Keisan::AST.parse("12 & 8")
      expect(ast.evaluate).to be_a(described_class)
      expect(ast.evaluate.value).to eq 8

      ast = Keisan::AST.parse("4 | 8")
      expect(ast.evaluate).to be_a(described_class)
      expect(ast.evaluate.value).to eq 12

      ast = Keisan::AST.parse("3 ^ 6")
      expect(ast.evaluate).to be_a(described_class)
      expect(ast.evaluate.value).to eq 5

      ast = Keisan::AST.parse("4 << 2")
      expect(ast.evaluate).to be_a(described_class)
      expect(ast.evaluate.value).to eq 16

      ast = Keisan::AST.parse("0b1111 >> 2")
      expect(ast.evaluate).to be_a(described_class)
      expect(ast.evaluate.value).to eq 0b11

      ast = Keisan::AST.parse("4 > 4")
      expect(ast.evaluate).to be_a(Keisan::AST::Boolean)
      expect(ast.evaluate.value).to eq false

      ast = Keisan::AST.parse("4 >= 4")
      expect(ast.evaluate).to be_a(Keisan::AST::Boolean)
      expect(ast.evaluate.value).to eq true

      ast = Keisan::AST.parse("4 < 4")
      expect(ast.evaluate).to be_a(Keisan::AST::Boolean)
      expect(ast.evaluate.value).to eq false

      ast = Keisan::AST.parse("4 <= 4")
      expect(ast.evaluate).to be_a(Keisan::AST::Boolean)
      expect(ast.evaluate.value).to eq true

      ast = Keisan::AST.parse("4 == 4")
      expect(ast.evaluate).to be_a(Keisan::AST::Boolean)
      expect(ast.evaluate.value).to eq true

      ast = Keisan::AST.parse("4 != 4")
      expect(ast.evaluate).to be_a(Keisan::AST::Boolean)
      expect(ast.evaluate.value).to eq false
    end
  end

  describe "operations" do
    it "should reduce to the answer right away" do
      res = 10 - Keisan::AST::Number.new(3)
      expect(res).to be_a(described_class)
      expect(res.value).to eq 7

      res = Keisan::AST::Number.new(10) - 3
      expect(res).to be_a(described_class)
      expect(res.value).to eq 7

      res = Keisan::AST::Number.new(5) % 3
      expect(res).to be_a(described_class)
      expect(res.value).to eq 2

      res = 5 % Keisan::AST::Number.new(3)
      expect(res).to be_a(described_class)
      expect(res.value).to eq 2

      res = Keisan::AST::Number.new(3) ** 4
      expect(res).to be_a(described_class)
      expect(res.value).to eq 81

      res = 3 ** Keisan::AST::Number.new(4)
      expect(res).to be_a(described_class)
      expect(res.value).to eq 81
    end
  end
end

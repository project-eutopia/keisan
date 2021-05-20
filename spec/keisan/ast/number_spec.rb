require "spec_helper"

RSpec.describe Keisan::AST::Number do
  describe "is_constant?" do
    it "is true" do
      expect(Keisan::AST::Number.new(1).is_constant?).to eq true
    end
  end

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

    it "stays as an AST when using non-number" do
      ast = Keisan::AST.parse("1+x")
      expect(ast.evaluate).to be_a(Keisan::AST::Plus)

      ast = Keisan::AST.parse("1-x")
      expect(ast.evaluate).to be_a(Keisan::AST::Plus)

      ast = Keisan::AST.parse("1*x")
      expect(ast.evaluate).to be_a(Keisan::AST::Times)

      ast = Keisan::AST.parse("1/x")
      expect(ast.evaluate).to be_a(Keisan::AST::Times)

      ast = Keisan::AST.parse("1%x")
      expect(ast.evaluate).to be_a(Keisan::AST::Modulo)

      ast = Keisan::AST.parse("2**x")
      expect(ast.evaluate).to be_a(Keisan::AST::Exponent)

      ast = Keisan::AST.parse("+x")
      expect(ast.evaluate).to be_a(Keisan::AST::Variable)

      ast = Keisan::AST.parse("-x")
      expect(ast.evaluate).to be_a(Keisan::AST::UnaryMinus)

      ast = Keisan::AST.parse("~x")
      expect(ast.evaluate).to be_a(Keisan::AST::UnaryBitwiseNot)

      ast = Keisan::AST.parse("1&x")
      expect(ast.evaluate).to be_a(Keisan::AST::BitwiseAnd)

      ast = Keisan::AST.parse("1|x")
      expect(ast.evaluate).to be_a(Keisan::AST::BitwiseOr)

      ast = Keisan::AST.parse("1^x")
      expect(ast.evaluate).to be_a(Keisan::AST::BitwiseXor)

      ast = Keisan::AST.parse("1<<x")
      expect(ast.evaluate).to be_a(Keisan::AST::BitwiseLeftShift)

      ast = Keisan::AST.parse("1>>x")
      expect(ast.evaluate).to be_a(Keisan::AST::BitwiseRightShift)

      ast = Keisan::AST.parse("1>x")
      expect(ast.evaluate).to be_a(Keisan::AST::LogicalGreaterThan)

      ast = Keisan::AST.parse("1>=x")
      expect(ast.evaluate).to be_a(Keisan::AST::LogicalGreaterThanOrEqualTo)

      ast = Keisan::AST.parse("1<x")
      expect(ast.evaluate).to be_a(Keisan::AST::LogicalLessThan)

      ast = Keisan::AST.parse("1<=x")
      expect(ast.evaluate).to be_a(Keisan::AST::LogicalLessThanOrEqualTo)

      ast = Keisan::AST.parse("1==x")
      expect(ast.evaluate).to be_a(Keisan::AST::LogicalEqual)

      ast = Keisan::AST.parse("1!=x")
      expect(ast.evaluate).to be_a(Keisan::AST::LogicalNotEqual)
    end

    it "has definite behavior for other constants" do
      ast = Keisan::AST.parse("1+'a'")
      expect{ast.evaluate}.to raise_error(Keisan::Exceptions::InvalidExpression)

      ast = Keisan::AST.parse("1-'a'")
      expect{ast.evaluate}.to raise_error(Keisan::Exceptions::InvalidExpression)

      ast = Keisan::AST.parse("1*'a'")
      expect{ast.evaluate}.to raise_error(Keisan::Exceptions::InvalidExpression)

      ast = Keisan::AST.parse("1/'a'")
      expect{ast.evaluate}.to raise_error(Keisan::Exceptions::InvalidExpression)

      ast = Keisan::AST.parse("1%'a'")
      expect{ast.evaluate}.to raise_error(Keisan::Exceptions::InvalidExpression)

      ast = Keisan::AST.parse("2**'a'")
      expect{ast.evaluate}.to raise_error(Keisan::Exceptions::InvalidExpression)

      ast = Keisan::AST.parse("1&'a'")
      expect{ast.evaluate}.to raise_error(Keisan::Exceptions::InvalidExpression)

      ast = Keisan::AST.parse("1|'a'")
      expect{ast.evaluate}.to raise_error(Keisan::Exceptions::InvalidExpression)

      ast = Keisan::AST.parse("1^'a'")
      expect{ast.evaluate}.to raise_error(Keisan::Exceptions::InvalidExpression)

      ast = Keisan::AST.parse("1<<'a'")
      expect{ast.evaluate}.to raise_error(Keisan::Exceptions::InvalidExpression)

      ast = Keisan::AST.parse("1>>'a'")
      expect{ast.evaluate}.to raise_error(Keisan::Exceptions::InvalidExpression)

      ast = Keisan::AST.parse("1>'a'")
      expect{ast.evaluate}.to raise_error(Keisan::Exceptions::InvalidExpression)

      ast = Keisan::AST.parse("1>='a'")
      expect{ast.evaluate}.to raise_error(Keisan::Exceptions::InvalidExpression)

      ast = Keisan::AST.parse("1<'a'")
      expect{ast.evaluate}.to raise_error(Keisan::Exceptions::InvalidExpression)

      ast = Keisan::AST.parse("1<='a'")
      expect{ast.evaluate}.to raise_error(Keisan::Exceptions::InvalidExpression)

      ast = Keisan::AST.parse("1=='a'")
      expect(ast.evaluate).to be_a(Keisan::AST::Boolean)
      expect(ast.evaluate.value).to eq false

      ast = Keisan::AST.parse("1!='a'")
      expect(ast.evaluate).to be_a(Keisan::AST::Boolean)
      expect(ast.evaluate.value).to eq true
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

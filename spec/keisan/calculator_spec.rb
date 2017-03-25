require "spec_helper"

RSpec.describe Keisan::Calculator do
  let(:calculator) { described_class.new }

  it "calculates correctly" do
    expect(calculator.evaluate("1 + 2")).to eq 3
    expect(calculator.evaluate("2*x + 4", x: 3)).to eq 10
    expect(calculator.evaluate("2 / 3 ** 2")).to eq Rational(2,9)
  end

  it "can handle custom functions" do
    expect(calculator.evaluate("2*f(x) + 4", x: 3, f: Proc.new {|x| x**2})).to eq 2*9+4
  end

  context "list operations" do
    it "evaluates lists" do
      expect(calculator.evaluate("[2, 3, 5, 8]")).to eq [2,3,5,8]
    end

    it "can index lists" do
      expect(calculator.evaluate("[[1,2,3],[4,5,6],[7,8,9]][1][2]")).to eq 6
    end

    it "can concatenate lists using +" do
      expect(calculator.evaluate("[3, 5] + [10, 11]")).to eq [3, 5, 10, 11]
    end
  end

  describe "defining variables and functions" do
    it "saves them in the calculators context" do
      calculator.define_variable!("x", 5)
      expect(calculator.evaluate("x + 1")).to eq 6
      expect(calculator.evaluate("x + 1", x: 10)).to eq 11
      expect(calculator.evaluate("x + 1")).to eq 6

      calculator.define_function!("f", Proc.new {|x| 3*x})
      expect(calculator.evaluate("f(2)")).to eq 6
      expect(calculator.evaluate("f(2)", f: Proc.new {|x| 10*x})).to eq 20
      expect(calculator.evaluate("f(2)")).to eq 6
      expect(calculator.evaluate("2.f")).to eq 6
      expect(calculator.evaluate("2.f()")).to eq 6
    end
  end

  context "dot operators mixed with list indexings" do
    it "parses in correct order" do
      calculator.define_function!("f", Proc.new {|x| [[x-1,x+1], [x-2,x,x+2]]})
      expect(calculator.evaluate("4.f")).to eq [[3,5], [2,4,6]]
      expect(calculator.evaluate("4.f[0]")).to eq [3,5]
      expect(calculator.evaluate("4.f[0].size")).to eq 2
      expect(calculator.evaluate("4.f[1]")).to eq [2,4,6]
      expect(calculator.evaluate("4.f[1].size")).to eq 3
    end
  end

  context "modulo operator" do
    it "works as expected" do
      expect(calculator.evaluate("95 % 7 % 5")).to eq 4
      expect(calculator.evaluate("(95 % 7) % 5")).to eq 4
      expect(calculator.evaluate("95 % (7 % 5)")).to eq 1
    end
  end
end

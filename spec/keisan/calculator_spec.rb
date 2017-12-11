require "spec_helper"

RSpec.describe Keisan::Calculator do
  let(:calculator) { described_class.new }

  it "calculates correctly" do
    expect(calculator.evaluate("1 + 2")).to eq 3
    expect(calculator.evaluate("2*x + 4", x: 3)).to eq 10
    expect(calculator.evaluate("2 / 3 ** 2")).to eq Rational(2,9)
  end

  it "does nothing for blank strings" do
    expect(calculator.evaluate("  ")).to eq nil
  end

  it "ignores comments" do
    expect(calculator.evaluate("2 + 3 # 4")).to eq 5
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

  describe "defining variables" do
    it "raises an error if there is an undefined variable" do
      expect{calculator.evaluate("x = y")}.to raise_error(Keisan::Exceptions::InvalidExpression)
    end

    it "can define variables" do
      expect(calculator.evaluate("y = 2")).to eq 2
      expect(calculator.evaluate("y")).to eq 2

      expect(calculator.evaluate("x = 2*y")).to eq 4
      expect(calculator.evaluate("3*x + y**2")).to eq 12 + 4
    end

    context "with definitions" do
      it "raises an error if there is an undefined variable" do
        calculator.evaluate("x = n", n: 10)
        expect{calculator.evaluate("n")}.to raise_error(Keisan::Exceptions::UndefinedVariableError)
        expect(calculator.evaluate("x")).to eq 10
      end
    end
  end

  describe "defining functions" do
    it "raises an error if there is an undefined variable" do
      expect{calculator.evaluate("f(x) = n*x")}.to raise_error(Keisan::Exceptions::InvalidExpression)
    end

    it "can define functions" do
      calculator.evaluate("f(x) = 4*x")
      expect(calculator.evaluate("f(3)")).to eq 12

      calculator.evaluate("g(x,y) = -2*x + f(y)")
      expect(calculator.evaluate("g(7, 5)")).to eq -2*7 + 4*5
    end

    context "with definitions" do
      it "local variables are evaluated, i.e. only function arguments remain variables" do
        calculator.evaluate("a = 2")
        calculator.evaluate("f(x) = a*n*x + g(x)", n: 10, g: Proc.new {|x| x**2})
        expect(calculator.evaluate("f(3)")).to eq (60 + 3**2)
        calculator.evaluate("a = 3")
        calculator.evaluate("g(x) = 0")
        expect(calculator.evaluate("f(3)")).to eq (60 + 3**2)
      end
    end

    context "recursive" do
      context "cannot define recursive functions" do
        let(:calculator) { described_class.new(allow_recursive: false) }

        it "can define factorial" do
          expect {
            calculator.evaluate("my_fact(n) = if (n > 1, n*my_fact(n-1), 1)")
          }.to raise_error(Keisan::Exceptions::InvalidExpression)
        end
      end

      context "can define recursive functions" do
        let(:calculator) { described_class.new(allow_recursive: true) }

        it "can define factorial" do
          calculator.evaluate("my_fact(n) = if (n > 1, n*my_fact(n-1), 1)")
          expect(calculator.evaluate("my_fact(0)")).to eq 1
          expect(calculator.evaluate("my_fact(1)")).to eq 1
          expect(calculator.evaluate("my_fact(5)")).to eq 120
        end
      end
    end
  end
end

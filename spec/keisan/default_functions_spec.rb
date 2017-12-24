require "spec_helper"

RSpec.describe Keisan::Functions::DefaultRegistry do
  let(:registry) { described_class.registry }
  it "contains correct functions" do
    expect(registry["sin"].name).to eq "sin"
    expect(registry["sin"].call(nil, 1).value).to eq Math.sin(1)
  end

  it "is unmodifiable" do
    expect { registry.register!(:bad, Proc.new { false }) }.to raise_error(Keisan::Exceptions::UnmodifiableError)
  end

  context "array methods" do
    it "works as expected" do
      expect(registry["min"].name).to eq "min"
      expect(registry["min"].call(nil, [-4, -1, 1, 2]).value).to eq -4

      expect(registry["max"].name).to eq "max"
      expect(registry["max"].call(nil, [-4, -1, 1, 2]).value).to eq 2

      expect(registry["size"].name).to eq "size"
      expect(registry["size"].call(nil, [-4, -1, 1, 2]).value).to eq 4

      expect(registry["reverse"].name).to eq "reverse"
      expect(registry["reverse"].call(nil, [1, 2, 3]).value).to eq [3, 2, 1]

      expect(registry["flatten"].name).to eq "flatten"
      expect(registry["flatten"].call(nil, [[1,2], [3,4]]).value).to eq [1, 2, 3, 4]

      expect(registry["range"].name).to eq "range"
      expect(registry["range"].call(nil, 5).value).to eq [0, 1, 2, 3, 4]
      expect(registry["range"].call(nil, 5, 10).value).to eq [5, 6, 7, 8, 9]
      expect(registry["range"].call(nil, 12, 22, 2).value).to eq [12, 14, 16, 18, 20]
      expect(registry["range"].call(nil, 10, 4, -2).value).to eq [10, 8, 6]

      expect(Keisan::Calculator.new.evaluate("a[size(a)-1]", a: [1, 3, 5, 7])).to eq 7
    end

    context "functional methods" do
      describe "#map" do
        it "maps the list to the given expression" do
          expect{Keisan::Calculator.new.evaluate("map(10, x, x**2)")}.to raise_error(Keisan::Exceptions::InvalidFunctionError)
          expect{Keisan::Calculator.new.evaluate("map([1,3,5], 4, x**2)")}.to raise_error(Keisan::Exceptions::InvalidFunctionError)
          expect(Keisan::Calculator.new.evaluate("map([1,3,5], x, x**2)")).to eq [1, 9, 25]
          expect(Keisan::Calculator.new.evaluate("collect([1,3,5], x, 2*x)")).to eq [2,6,10]
          expect(Keisan::Calculator.new.simplify("[1,3,5].map(x, y*x**2)").to_s).to eq "[y,9*y,25*y]"
        end

        it "shadows variable definitions" do
          calculator = Keisan::Calculator.new
          calculator.evaluate("x = 5")
          expect(calculator.evaluate("[1,2,3].map(x, x**2)")).to eq [1,4,9]
          expect(calculator.evaluate("[1,2,3].filter(x,x == 2)")).to eq [2]
          expect(calculator.evaluate("[1,2,3,4].inject(2*x, product, x, product*x)")).to eq 240
        end
      end

      describe "#filter" do
        it "filters the list given the logical expression" do
          expect{Keisan::Calculator.new.evaluate("filter(10, x, x > 0)")}.to raise_error(Keisan::Exceptions::InvalidFunctionError)
          expect{Keisan::Calculator.new.evaluate("filter([-1,0,1], 4, x > 0)")}.to raise_error(Keisan::Exceptions::InvalidFunctionError)
          expect(Keisan::Calculator.new.evaluate("filter([-1,0,1], x, x > 0)")).to eq [1]
          expect(Keisan::Calculator.new.evaluate("select([1,2,3,4], x, x % 2 == 0)")).to eq [2,4]
          expect(Keisan::Calculator.new.simplify("[1,3,5].filter(x, x == 3)").to_s).to eq "[3]"
        end
      end

      describe "#reduce" do
        it "reduces the list given expression" do
          expect{Keisan::Calculator.new.evaluate("reduce(1, 2, 3)")}.to raise_error(Keisan::Exceptions::InvalidFunctionError)
          expect{Keisan::Calculator.new.evaluate("reduce([-1,0,1], 4, 1, x, x+total)")}.to raise_error(Keisan::Exceptions::InvalidFunctionError)

          expect(Keisan::Calculator.new.simplify("reduce([1,2,3], init, total, x, total+x)").to_s).to eq "6+init"
          expect(Keisan::Calculator.new.evaluate("[1,2,3,4,5].inject(1, total, x, total*x)")).to eq 120
        end
      end

      context "first argument is function/variable that returns a list" do
        it "works properly" do
          calculator = Keisan::Calculator.new
          calculator.evaluate("l = [1,2,3,4,5]")

          expect(calculator.evaluate("l.map(x, 2*x)")).to eq [2, 4, 6, 8, 10]
          expect(calculator.evaluate("range(10).filter(x, x % 2 == 0)")).to eq [0, 2, 4, 6, 8]
          expect(calculator.evaluate("range(101).inject(0, total, x, total+x)")).to eq 5050
        end
      end
    end
  end

  context "random methods" do
    it "works as expected" do
      a = [2, 3, 6, 7]

      20.times do
        expect(0...4).to cover Keisan::Calculator.new.evaluate("rand(4)")
        expect(3...8).to cover Keisan::Calculator.new.evaluate("rand(3, 8)")
        expect(a).to include Keisan::Calculator.new.evaluate("sample(#{a})")
      end
    end

    it "uses correct Random object" do
      context1 = Keisan::Context.new(random: Random.new(1234))
      context2 = Keisan::Context.new(random: Random.new(1234))

      calc1 = Keisan::Calculator.new(context: context1)
      calc2 = Keisan::Calculator.new(context: context2)

      20.times do
        expect(calc1.evaluate("rand(100)")).to eq calc2.evaluate("rand(100)")
      end
    end
  end

  context "combinatorical methods" do
    it "works as expected" do
      calculator = Keisan::Calculator.new
      expect(calculator.evaluate("factorial(4)").value).to eq 24
      expect(calculator.evaluate("nPk(10, 2)").value).to eq 90
      expect(calculator.evaluate("10.permute(2)").value).to eq 90
      expect(calculator.evaluate("nCk(10, 2)").value).to eq 45
      expect(calculator.evaluate("10.choose(2)").value).to eq 45
    end
  end

  context "transcendental methods" do
    it "has correct evaluation" do
      calculator = Keisan::Calculator.new

      expect(calculator.evaluate("exp(1)")).to eq Math::E
      expect(calculator.evaluate("exp(PI*I)").real).to eq -1
      expect(calculator.evaluate("exp(PI*I)").imag.abs).to be <= 1e-15
      expect(calculator.evaluate("log(I)")).to eq 1i*Math::PI/2

      expect(calculator.evaluate("sin(2*I)")).to eq (1i*Math::sinh(2))
      expect(calculator.evaluate("cos(-3*I)")).to eq Math::cosh(-3)
      expect(calculator.evaluate("tan(-I)")).to eq (1i*Math::tanh(-1))
      expect(calculator.evaluate("csc(2*I)")).to eq (1i*Math::sinh(2))**-1
      expect(calculator.evaluate("sec(-3*I)")).to eq Math::cosh(-3)**-1
      expect(calculator.evaluate("cot(-I)")).to eq (1i*Math::tanh(-1))**-1

      expect(calculator.evaluate("sinh(2*I)")).to eq (1i*Math::sin(2))
      expect(calculator.evaluate("cosh(-3*I)")).to eq Math::cos(-3)
      expect(calculator.evaluate("tanh(-I)")).to be_within(1e-15).of (1i*Math::tan(-1))
      expect(calculator.evaluate("csch(2*I)")).to eq (1i*Math::sin(2))**-1
      expect(calculator.evaluate("sech(-3*I)")).to eq Math::cos(-3)**-1
      expect(calculator.evaluate("coth(-I)")).to be_within(1e-15).of (1i*Math::tan(-1))**-1

      expect(calculator.evaluate("sqrt(-4)")).to eq 2i
      expect(calculator.evaluate("cbrt(-8)")).to be_within(1e-15).of 1 + 1i*Math::sqrt(3)

      expect(calculator.evaluate("abs(3+4*I)")).to eq 5
      expect(calculator.evaluate("real(3+4*I)")).to eq 3
      expect(calculator.evaluate("imag(3+4*I)")).to eq 4
    end

    it "has correct derivative" do
      calculator = Keisan::Calculator.new

      expect(calculator.simplify("diff(exp(2*x), x)").to_s).to eq "2*exp(2*x)"
      expect(calculator.simplify("diff(log(2*x), x)").to_s).to eq "2*((2*x)**-1)"

      expect(calculator.simplify("diff(sin(2*x), x)").to_s).to eq "2*cos(2*x)"
      expect(calculator.simplify("diff(cos(2*x), x)").to_s).to eq "-2*sin(2*x)"
      expect(calculator.simplify("diff(tan(2*x), x)").to_s).to eq "2*(cos(2*x)**-2)"
      expect(calculator.simplify("diff(csc(2*x), x)").to_s).to eq "-2*cos(2*x)*(sin(2*x)**-2)"
      expect(calculator.simplify("diff(sec(2*x), x)").to_s).to eq "2*sin(2*x)*(cos(2*x)**-2)"
      expect(calculator.simplify("diff(cot(2*x), x)").to_s).to eq "-2*(sin(2*x)**-2)"

      expect(calculator.simplify("diff(sinh(2*x), x)").to_s).to eq "2*cosh(2*x)"
      expect(calculator.simplify("diff(cosh(2*x), x)").to_s).to eq "2*sinh(2*x)"
      expect(calculator.simplify("diff(tanh(2*x), x)").to_s).to eq "2*(cosh(2*x)**-2)"
      expect(calculator.simplify("diff(csch(2*x), x)").to_s).to eq "-2*cosh(2*x)*(sinh(2*x)**-2)"
      expect(calculator.simplify("diff(sech(2*x), x)").to_s).to eq "-2*sinh(2*x)*(cosh(2*x)**-2)"
      expect(calculator.simplify("diff(coth(2*x), x)").to_s).to eq "-2*(sinh(2*x)**-2)"

      expect(calculator.simplify("diff(sqrt(2*x), x)").to_s).to eq "(2*x)**(-1/2)"
      expect(calculator.simplify("diff(cbrt(2*x), x)").to_s).to eq "(2/3)*((2*x)**(-2/3))"
    end
  end
end

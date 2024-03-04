require "spec_helper"

RSpec.describe "Differentiation" do
  let(:calculator) { Keisan::Calculator.new }

  describe "diff of expression functions" do
    context "single variable" do
      it "can be used to assign variables" do
        calculator.evaluate("my_func(x) = x*log(x)")
        expect(calculator.evaluate("my_func(10)")).to be_within(0.0001).of(10 * Math::log(10))
        expect(calculator.evaluate("replace(diff(my_func(x), x), x, 10)")).to be_within(0.0001).of(1 + Math::log(10))
      end
    end

    context "two variables" do
      it "can be used to assign variables" do
        calculator.evaluate("my_func(x, y) = x*exp(x*y)")
        expect(calculator.evaluate("my_func(3, 5)")).to eq(3*Math::exp(15))

        expect(calculator.evaluate("replace(replace(diff(my_func(a, b), a), a, 2), b, 3)")).to eq(
          (2*3 + 1)*Math::exp(2*3)
        )

        expect(calculator.evaluate("replace(replace(diff(my_func(a**2, 1/b), a), a, 2), b, 1.5)")).to eq(
          2*2*(1 + 2**2/1.5) * Math::exp(2**2 / 1.5)
        )
      end
    end

    context "differentiation variable is an already defined variable" do
      it "does not interfere with differentiation" do
        calculator.evaluate("x = 5")
        calculator.evaluate("f(x) = x**2")
        expect(calculator.evaluate("f(10)")).to eq 100
        expect(calculator.evaluate("diff(f(x), x)")).to eq 10
      end
    end
  end
end

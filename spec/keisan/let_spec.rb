require "spec_helper"

RSpec.describe Keisan::Functions::Let do
  let(:calculator) { Keisan::Calculator.new }

  it "can be used to assign variables" do
    calculator.evaluate("let x = 4")
    expect(calculator.evaluate("2*x")).to eq 8
  end

  it "defines variables locally when in block" do
    calculator.evaluate("let x = 7")

    expect(calculator.evaluate("{let x = 11; x*2}")).to eq 22
    expect(calculator.evaluate("x")).to eq 7
    expect(calculator.evaluate("{x = 15; x}")).to eq 15
    expect(calculator.evaluate("x")).to eq 15
  end

  it "raises error for single argument when not assignment" do
    expect{calculator.evaluate("let x")}.to raise_error(Keisan::Exceptions::InvalidFunctionError)
  end

  it "works with two arguments for variable assignment" do
    calculator.evaluate("let(x, (10+20))")
    expect(calculator.evaluate("x").value).to eq 30
  end

  it "works in sub-expression" do
    calculator.evaluate("y = 2*let(x, 3)")
    expect(calculator.evaluate("x").value).to eq 3
    expect(calculator.evaluate("y").value).to eq 6
  end

  it "will create local definitions in children contexts" do
    calculator2 = Keisan::Calculator.new(context: calculator.context.spawn_child)

    calculator.evaluate("x = 10")
    calculator.evaluate("f(x) = x**2")

    calculator2.evaluate("x = 20")
    calculator2.evaluate("f(x) = x**3")

    expect(calculator.evaluate("x")).to eq 20
    expect(calculator.evaluate("f(2)")).to eq 8
    expect(calculator2.evaluate("x")).to eq 20
    expect(calculator2.evaluate("f(2)")).to eq 8

    calculator2.evaluate("let x = 30")
    calculator2.evaluate("let f(x) = x**4")

    expect(calculator.evaluate("x")).to eq 20
    expect(calculator.evaluate("f(2)")).to eq 8
    expect(calculator2.evaluate("x")).to eq 30
    expect(calculator2.evaluate("f(2)")).to eq 16
  end
end

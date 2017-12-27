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
end

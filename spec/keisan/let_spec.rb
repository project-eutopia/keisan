require "spec_helper"

RSpec.describe Keisan::Functions::Let do
  it "can be used to assign variables" do
    calculator = Keisan::Calculator.new
    calculator.evaluate("let x = 4")
    expect(calculator.evaluate("2*x")).to eq 8
  end

  it "defines variables locally when in block" do
    calculator = Keisan::Calculator.new
    calculator.evaluate("let x = 7")

    expect(calculator.evaluate("{let x = 11; x*2}")).to eq 22
    expect(calculator.evaluate("x")).to eq 7
  end
end

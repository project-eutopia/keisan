require "spec_helper"

RSpec.describe Keisan::Functions::While do
  it "does loops" do
    calculator = Keisan::Calculator.new
    calculator.evaluate("x = 0")
    calculator.evaluate("while(x < 10, x = x + 1)")
    expect(calculator.evaluate("x")).to eq 10
  end
end

require "spec_helper"

RSpec.describe Compute::Calculator do
  it "calculates correctly" do
    calc = described_class.new

    expect(calc.evaluate("1 + 2")).to eq 3
    expect(calc.evaluate("2*x + 4", x: 3)).to eq 10
    expect(calc.evaluate("2 / 3 ** 2")).to eq Rational(2,9)
  end
end

require "spec_helper"

RSpec.describe Keisan::Functions::Puts do
  let(:calculator) { Keisan::Calculator.new }

  it "outputs to STDOUT" do
    expect { calculator.evaluate("puts 123") }.to output("123\n").to_stdout
    expect { calculator.evaluate("puts(x**2 + 1)") }.to output("(x**2)+1\n").to_stdout
    calculator.evaluate("x = 2")
    expect { calculator.evaluate("puts(x**2 + 1)") }.to output("5\n").to_stdout
  end
end

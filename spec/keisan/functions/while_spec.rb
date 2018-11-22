require "spec_helper"

RSpec.describe Keisan::Functions::While do
  it "does loops" do
    calculator = Keisan::Calculator.new

    calculator.evaluate("x = 0")
    calculator.evaluate("while(x < 10, x = x + 1)")
    expect(calculator.evaluate("x")).to eq 10

    calculator.evaluate(<<-KEISAN
                        includes(a, element) = {
                          let i = 0;
                          let found = false;
                          while (i < a.size,
                            if (a[i] == element,
                              found = true;
                              i = a.size
                            )
                            i += 1
                          );
                          found
                        }
    KEISAN
                       )
    expect(calculator.evaluate("[1,2,3].includes(2)")).to eq true
    expect(calculator.evaluate("[1,2,3].includes(4)")).to eq false
  end
end

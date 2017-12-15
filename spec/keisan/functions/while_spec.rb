require "spec_helper"

RSpec.describe Keisan::Functions::While do
  it "works with simple incrementing expression" do
    calculator = Keisan::Calculator.new
    calculator.evaluate("x = 0")
    calculator.evaluate("while(x < 10, x = x + 1)")
    expect(calculator.evaluate("x")).to eq 10
  end

  it "raises InvalidFunctionError when condition is not boolean" do
    calculator = Keisan::Calculator.new
    calculator.evaluate("x = 0")
    expect{calculator.evaluate("while(x, x+1)")}.to raise_error(Keisan::Exceptions::InvalidFunctionError)
  end

  it "works with complex multi line operations" do
    calculator = Keisan::Calculator.new

    ast = calculator.ast(
      <<-KEISAN
        l = []
        i = 0
        while (i < 5,
          l = l + [i**2]
          i = i + 1
        )
        l
      KEISAN
    )

    expect(ast.evaluate.value).to eq [0, 1, 4, 9, 16]
  end
end

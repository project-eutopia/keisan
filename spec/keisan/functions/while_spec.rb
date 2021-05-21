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

  describe "simplify" do
    it "evaluates while loop if given boolean" do
      calculator = Keisan::Calculator.new
      calculator.evaluate("x = 0")
      res = calculator.simplify("while(x < 4, x = x + 1); x")
      expect(res).to be_a(Keisan::AST::Number)
      expect(res.value).to eq 4
    end

    it "raises an error if given a constant non-boolean" do
      calculator = Keisan::Calculator.new
      calculator.evaluate("x = 0")
      expect{calculator.simplify("while(!x, x = x + 1); x")}.to raise_error(Keisan::Exceptions::InvalidFunctionError)
    end

    it "leaves as original AST if cannot determine what the logical field is" do
      calculator = Keisan::Calculator.new
      res = calculator.simplify("while(!x, x = x + 1)")
      expect(res).to be_a(Keisan::AST::Function)
      expect(res.name).to eq "while"
    end
  end

  describe "evaluate" do
    it "evaluates while loop if given boolean" do
      calculator = Keisan::Calculator.new
      calculator.evaluate("x = 0")
      expect(calculator.evaluate("while(x < 4, x = x + 1); x")).to eq 4
    end

    it "raises an error if given a constant non-boolean" do
      calculator = Keisan::Calculator.new
      calculator.evaluate("x = 0")
      expect{calculator.evaluate("while(!x, x = x + 1); x")}.to raise_error(Keisan::Exceptions::InvalidFunctionError)
    end

    it "raises an error if cannot determine what the logical field is" do
      calculator = Keisan::Calculator.new
      expect{calculator.evaluate("while(!x, x = x + 1)")}.to raise_error(Keisan::Exceptions::InvalidFunctionError)
    end
  end
end

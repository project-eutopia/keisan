require "spec_helper"

RSpec.describe Keisan::Functions::Puts do
  let(:calculator) { Keisan::Calculator.new }

  it "outputs to STDOUT" do
    expect { calculator.evaluate("puts 123") }.to output("123\n").to_stdout
    expect { calculator.evaluate("puts(x**2 + 1)") }.to output("(x**2)+1\n").to_stdout
    calculator.evaluate("x = 2")
    expect { calculator.evaluate("puts(x**2 + 1)") }.to output("5\n").to_stdout
  end

  describe "evaluate" do
    it "returns null" do
      expect {
        ast = calculator.ast("puts x = 5")
        expect(ast.evaluate).to eq Keisan::AST::Null.new
      }.to output("5\n").to_stdout
    end

    it "does evaluation of arguments" do
      expect { calculator.evaluate("puts(x = 12)") }.to output("12\n").to_stdout
      expect(calculator.evaluate("x")).to eq 12
    end
  end

  describe "#value and #simplify call evaluate" do
    it "value calls evaluate" do
      expect_any_instance_of(Keisan::Functions::Puts).to receive(:evaluate).and_return(Keisan::AST::Null.new)
      ast = calculator.ast("puts x = 5")
      expect(ast.value).to eq Keisan::AST::Null.new
    end

    it "simplify calls evaluate" do
      expect_any_instance_of(Keisan::Functions::Puts).to receive(:evaluate).and_return(Keisan::AST::Null.new)
      ast = calculator.ast("puts x = 5")
      expect(ast.simplify).to eq Keisan::AST::Null.new
    end
  end
end

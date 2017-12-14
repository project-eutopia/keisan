require "spec_helper"

RSpec.describe Keisan::Functions::If do
  it "should be in the default context" do
    c = Keisan::Context.new
    expect(c.function("if")).to be_a(described_class)
  end

  describe "simplify" do
    it "short circuits if the conditional is a boolean" do
      ast = Keisan::AST.parse("if(N, x, y)")
      expect(ast.simplify.to_s).to eq "if(N,x,y)"

      ast = Keisan::AST.parse("if(true, x, y)")
      expect(ast.simplify.to_s).to eq "x"

      ast = Keisan::AST.parse("if(false, x, y)")
      expect(ast.simplify.to_s).to eq "y"
    end
  end

  describe "differentiate" do
    it "passes through to if/else blocks" do
      c = Keisan::Context.new
      ast_def = Keisan::AST.parse("f(x) = if (x > 0, 2*x, -x**5)")
      ast_def.evaluate(c)

      ast_diff = Keisan::AST.parse("diff(f(x), x)")
      evaluation = ast_diff.evaluate(c)
      expect(evaluation.to_s).to eq "if(x>0,2,-5*(x**4))"
    end
  end

  it "returns nil if no else expression and boolean is false" do
    calculator = Keisan::Calculator.new
    calculator.evaluate("x = -10")
    expect(calculator.evaluate("if(x > 0, y = 1)")).to eq nil
  end

  it "can do assignment inside blocks" do
    calculator = Keisan::Calculator.new
    calculator.evaluate("x = 5")
    calculator.evaluate("if(x > 0, y = 1, y = 2)")
    expect(calculator.evaluate("y")).to eq 1
    calculator.evaluate("if(x < 0, z = 1, z = 2)")
    expect(calculator.evaluate("z")).to eq 2
  end
end

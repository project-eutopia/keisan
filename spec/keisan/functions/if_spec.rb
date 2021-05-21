require "spec_helper"

RSpec.describe Keisan::Functions::If do
  it "should be in the default context" do
    c = Keisan::Context.new
    expect(c.function("if")).to be_a(described_class)
  end

  it "can use logical values from variables" do
    calculator = Keisan::Calculator.new
    calculator.evaluate("a = true")
    calculator.evaluate("b = false")
    expect(calculator.evaluate("if(a, 5, 10)")).to eq 5
    expect(calculator.evaluate("if(b, 5, 10)")).to eq 10
  end

  it "can use logical values from lists" do
    calculator = Keisan::Calculator.new
    calculator.evaluate("l = [true, false]")
    expect(calculator.evaluate("if(l[0], 5, 10)")).to eq 5
    expect(calculator.evaluate("if(l[1], 5, 10)")).to eq 10
  end

  it "can use logical values from hashes" do
    calculator = Keisan::Calculator.new
    calculator.evaluate("h = {'a': true, 'b': false}")
    expect(calculator.evaluate("if(h['a'], 5, 10)")).to eq 5
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

  it "must have boolean in condition expression" do
    calculator = Keisan::Calculator.new
    calculator.evaluate("x = 0")
    expect{calculator.simplify("if(x, 1, 2)")}.to raise_error(Keisan::Exceptions::InvalidFunctionError)
    expect{calculator.simplify("if('foo', 'bar', 'baz')")}.to raise_error(Keisan::Exceptions::InvalidFunctionError)
    expect{calculator.evaluate("if(x, 1, 2)")}.to raise_error(Keisan::Exceptions::InvalidFunctionError)
    expect{calculator.evaluate("if('foo', 'bar', 'baz')")}.to raise_error(Keisan::Exceptions::InvalidFunctionError)
  end
end

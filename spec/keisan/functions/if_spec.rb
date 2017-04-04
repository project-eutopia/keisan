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
end

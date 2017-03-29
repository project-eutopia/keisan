require "spec_helper"

RSpec.describe Keisan::AST::Times do
  it "is left associative" do
    ast = Keisan::AST.parse("x * 5 * f(y) * (1*2) * zzz")
    expect(ast.to_s).to eq ("(((x*5)*f(y))*(1*2))*zzz")

    simple = ast.simplified
    expect(simple).to be_a(Keisan::AST::Times)
    expect(simple.children.map(&:class)).to match_array([
      Keisan::AST::Number,
      Keisan::AST::Variable,
      Keisan::AST::Variable,
      Keisan::AST::Function
    ])

    expect(simple.children.first.value).to eq 10
  end
end

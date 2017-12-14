require "spec_helper"

RSpec.describe Keisan::AST::UnaryIdentity do
  describe "simplify" do
    it "eliminates UnaryIdentity" do
      ast = Keisan::AST::UnaryIdentity.new([Keisan::AST::Variable.new("x")])
      expect(ast.simplified).to be_a(Keisan::AST::Variable)
      expect(ast.simplified.name).to eq "x"
    end
  end

  describe "value" do
    it "eliminates UnaryIdentity" do
      ast = Keisan::AST::UnaryIdentity.new([Keisan::AST::Number.new(12)])
      expect(ast.value).to eq 12
    end
  end

  describe "evaluate" do
    it "eliminates UnaryIdentity" do
      ast = Keisan::AST::UnaryIdentity.new([Keisan::AST::Number.new(12)])
      expect(ast.evaluate.value).to eq 12
    end
  end

  describe "differentiate" do
    it "eliminates UnaryIdentity" do
      ast = Keisan::AST::UnaryIdentity.new([Keisan::AST::Function.new(Keisan::AST::Variable.new("x"), "f")])
      diff = ast.differentiate(Keisan::AST::Variable.new("x"))
      expect(diff).to be_a(Keisan::AST::Function)
      expect(diff.name).to eq "diff"
      expect(diff.children.first).to be_a(Keisan::AST::Function)
      expect(diff.children.first.name).to eq "f"
    end
  end
end

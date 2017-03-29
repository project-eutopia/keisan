require "spec_helper"

RSpec.describe Keisan::AST::UnaryIdentity do
  describe "simplify" do
    it "eliminates UnaryIdentity" do
      ast = Keisan::AST::UnaryIdentity.new([Keisan::AST::Variable.new("x")])
      expect(ast.simplified).to be_a(Keisan::AST::Variable)
      expect(ast.simplified.name).to eq "x"
    end
  end
end

require "spec_helper"

RSpec.describe Keisan::AST::Indexing do
  describe "evaluate" do
    it "reduces to the element when operating on list" do
      ast = Keisan::AST.parse("[2,4,6]")
      expect(ast.evaluate).to be_a(Keisan::AST::List)
      expect(ast.evaluate.value).to eq [2, 4, 6]

      ast = Keisan::AST.parse("[[2, 4], [3, 9]][1]")
      expect(ast.evaluate).to be_a(Keisan::AST::Cell)
      expect(ast.evaluate.node).to be_a(Keisan::AST::List)
      expect(ast.evaluate.value).to eq [3, 9]

      ast = Keisan::AST.parse("[[2, 4], [3, 9]][1][0]")
      expect(ast.evaluate).to be_a(Keisan::AST::Cell)
      expect(ast.evaluate.node).to be_a(Keisan::AST::Number)
      expect(ast.evaluate.value).to eq 3
    end
  end
end

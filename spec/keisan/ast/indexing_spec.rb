require "spec_helper"

RSpec.describe Keisan::AST::Indexing do
  describe "evaluate" do
    it "reduces to the element when operating on list" do
      ast = Keisan::AST.parse("[2,4,6]")
      expect(ast.evaluate).to be_a(Keisan::AST::List)
      expect(ast.evaluate.value).to eq [2, 4, 6]

      ast = Keisan::AST.parse("[[2, 4], [3, 9]][1]")
      expect(ast.evaluate).to be_a(Keisan::AST::List)
      expect(ast.evaluate.value).to eq [3, 9]

      ast = Keisan::AST.parse("[[2, 4], [3, 9]][1][0]")
      expect(ast.evaluate).to be_a(Keisan::AST::Number)
      expect(ast.evaluate.value).to eq 3
    end
  end

  describe "#deep_dup" do
    it "duplicates the argument and index" do
      ast1 = Keisan::AST.parse("x[i+1]")
      ast2 = ast1.deep_dup

      expect(ast1.children.size).to eq 1
      expect(ast2.children.size).to eq 1
      expect(ast1.children.first).not_to equal(ast2.children.first)

      expect(ast1.indexes.size).to eq 1
      expect(ast2.indexes.size).to eq 1
      expect(ast1.indexes.first).not_to equal(ast2.indexes.first)
    end
  end

  describe "#freeze" do
    it "freezes indexes and children" do
      ast = Keisan::AST.parse("x[i+1]")

      expect(ast).not_to be_frozen
      expect(ast.children.any?(&:frozen?)).to be false
      expect(ast.indexes.any?(&:frozen?)).to be false

      ast.freeze

      expect(ast).to be_frozen
      expect(ast.children.all?(&:frozen?)).to be true
      expect(ast.indexes.all?(&:frozen?)).to be true
    end
  end
end

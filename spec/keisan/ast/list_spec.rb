require "spec_helper"

RSpec.describe Keisan::AST::List do
  describe "is_constant?" do
    it "is true when all elements are constant" do
      list = [[1,"x"],[2,"y",true]].to_node
      expect(list.is_constant?).to eq true
    end

    it "is false if one element is not constant" do
      list = described_class.new([
        "a".to_node, Keisan::AST::Variable.new("x")
      ])
      expect(list.is_constant?).to eq false
    end
  end

  describe "to_node" do
    it "can created nested lists" do
      node = [[1,"x"],[2,"y",true]].to_node
      expect(node).to be_a(described_class)

      expect(node.children.count).to eq 2
      expect(node.children.all? {|child| child.is_a?(described_class)}).to eq true

      expect(node.children[0].children.count).to eq 2
      expect(node.children[0].children[0]).to eq(Keisan::AST::Number.new(1))
      expect(node.children[0].children[1]).to eq(Keisan::AST::String.new("x"))

      expect(node.children[1].children.count).to eq 3
      expect(node.children[1].children[0]).to eq(Keisan::AST::Number.new(2))
      expect(node.children[1].children[1]).to eq(Keisan::AST::String.new("y"))
      expect(node.children[1].children[2]).to eq(Keisan::AST::Boolean.new(true))
    end
  end

  describe "simplify" do
    it "should concatenate lists if possible" do
      calculator = Keisan::Calculator.new
      result = calculator.simplify("[1,2] + [3,4]")
      expect(result.to_s).to eq "[1,2,3,4]"
    end
  end
end

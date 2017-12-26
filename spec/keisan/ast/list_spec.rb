require "spec_helper"

RSpec.describe Keisan::AST::List do
  describe "to_node" do
    it "can created nested lists" do
      node = [[1,"x"],[2,"y",true]].to_node
      expect(node).to be_a(described_class)

      expect(node.children.count).to eq 2
      expect(node.children.map(&:node).all? {|child| child.is_a?(described_class)}).to eq true

      expect(node.children[0].node.children.count).to eq 2
      expect(node.children[0].node.children[0].node).to eq(Keisan::AST::Number.new(1))
      expect(node.children[0].node.children[1].node).to eq(Keisan::AST::String.new("x"))

      expect(node.children[1].node.children.count).to eq 3
      expect(node.children[1].node.children[0].node).to eq(Keisan::AST::Number.new(2))
      expect(node.children[1].node.children[1].node).to eq(Keisan::AST::String.new("y"))
      expect(node.children[1].node.children[2].node).to eq(Keisan::AST::Boolean.new(true))
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

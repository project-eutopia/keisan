require "spec_helper"

RSpec.describe Keisan::AST::Cell do
  let(:node) { Keisan::AST::Node.new }
  let(:cell) { described_class.new(node) }

  describe "delegation of methods" do
    %i(unbound_variables unbound_functions value evaluate simplify evaluate_assignments to_s).each do |method|
      it "delegates #{method} to internal node" do
        expect(node).to receive(method)
        cell.send(method)
      end
    end

    it "delegates differentiate to internal node" do
      variable = Keisan::AST::Variable.new("x")
      expect(node).to receive(:differentiate).with(variable, nil)
      cell.differentiate(variable, nil)
    end

    it "delegates replace to internal node" do
      variable = Keisan::AST::Variable.new("x")
      number = Keisan::AST::Number.new(5)
      expect(node).to receive(:replace).with(variable, number)
      cell.replace(variable, number)
    end
  end

  describe "#to_node" do
    it "returns internal node" do
      expect(cell.to_node).to eq node
    end
  end

  describe "#to_cell" do
    it "wraps the node in a new cell" do
      new_cell = cell.to_cell
      expect(cell).not_to eq new_cell
      expect(cell.node).to eq new_cell.node
    end
  end
end

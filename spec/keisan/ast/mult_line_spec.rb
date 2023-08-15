require "spec_helper"

RSpec.describe Keisan::AST::MultiLine do
  describe "unbound_variables" do
    it "accounts for variables assigned internally" do
      node = Keisan::AST.parse("x = x; x")
      expect(node.unbound_variables).to eq Set.new(["x"])

      node = Keisan::AST.parse("x = y; x")
      expect(node.unbound_variables).to eq Set.new(["y"])

      node = Keisan::AST.parse("x = 1; y = 1; x + y")
      expect(node.unbound_variables).to eq Set.new

      node = Keisan::AST.parse("x = 1; y = x; x + y")
      expect(node.unbound_variables).to eq Set.new

      node = Keisan::AST.parse("x = 1; y = x + z; y")
      expect(node.unbound_variables).to eq Set.new(["z"])
    end
  end
end
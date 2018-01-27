require "spec_helper"

RSpec.describe Keisan::AST::Hash do
  describe "to_node" do
    it "can created nested hashes" do
      hash = {"foo" => {"a" => 1, "b" => 2}, "bar" => {"c" => 3, "d" => 4}}.to_node
      expect(hash).to be_a(described_class)

      expect(hash.keys).to match_array %w(foo bar)
      expect(hash.values.all? {|val| val.is_a?(described_class)}).to eq true

      expect(hash["foo"].keys).to match_array %w(a b)
      expect(hash["bar"].keys).to match_array %w(c d)
    end
  end

  describe "to_h method" do
    it "leaves hashes alone" do
      calculator = Keisan::Calculator.new
      expect(calculator.evaluate("{'a': 3, 'b': 7}.to_h").value).to eq({"a" => 3, "b" => 7})
    end

    it "converts lists of key,value pairs to hashes" do
      calculator = Keisan::Calculator.new
      expect(calculator.evaluate("[['a', 3], ['b', 7]].to_h").value).to eq({"a" => 3, "b" => 7})
    end
  end
end

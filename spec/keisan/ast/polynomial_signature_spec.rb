require "spec_helper"

RSpec.describe Keisan::AST::PolynomialSignature do
  it "is a hash" do
    expect(described_class.new).to be_a(Hash)
  end

  describe "new" do
    it "initializes from a hash" do
      expect(described_class.new({"a" => 1, "b" => 2})).to eq({"a" => 1, "b" => 2})
    end
  end

  describe "+" do
    it "cannot combine signatures" do
      expect(described_class.new({"a"=>1}) + described_class.new({"a"=>2})).to eq(
        {}
      )
    end
  end

  describe "*" do
    it "cannot combine signatures" do
      expect(described_class.new({"a"=>1,"b"=>2}) * described_class.new({"a"=>2})).to eq(
        {
          "a" => 3,
          "b" => 2
        }
      )
    end
  end

  describe "**" do
    it "cannot combine signatures" do
      expect(described_class.new({"a"=>1,"b"=>2}) ** 2).to eq(
        {
          "a" => 2,
          "b" => 4
        }
      )
    end
  end
end

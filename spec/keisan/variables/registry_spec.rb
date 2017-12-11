require "spec_helper"

RSpec.describe Keisan::Variables::Registry do
  let(:variables) { {} }
  let(:parent) { nil }
  let(:use_defaults) { true }
  let(:registry) { described_class.new(variables: variables, parent: parent, use_defaults: use_defaults) }

  context "with no parent, and using defaults" do
    it "raises error when not present" do
      expect{registry["not_exist"]}.to raise_error(Keisan::Exceptions::UndefinedVariableError)
    end

    it "retrieves default variables" do
      expect(registry["PI"].value).to eq Math::PI
      expect(registry["E"].value).to eq Math::E
      expect(registry["I"].value).to eq Complex(0,1)
    end

    it "can store and retrieve variables" do
      registry.register!("x", 4)
      expect(registry["x"].value).to eq 4
    end
  end

  context "when not using defaults" do
    let(:use_defaults) { false }
    it "raises error when getting a default variable" do
      expect{registry["PI"].value}.to raise_error(Keisan::Exceptions::UndefinedVariableError)
    end
  end

  context "with parent registry" do
    let(:parent_registry) do
      r = described_class.new
      r.register!("x", 5)
      r
    end

    let(:parent) { parent_registry }

    it "gets variable from the parent" do
      expect(registry["x"].value).to eq 5
    end

    it "can shadow parent variables" do
      registry.register!("x", 11)

      expect(registry["x"].value).to eq 11
      expect(parent_registry["x"].value).to eq 5
    end
  end
end

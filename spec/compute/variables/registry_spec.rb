require "spec_helper"

RSpec.describe Compute::Variables::Registry do
  let(:variables) { {} }
  let(:parent) { nil }
  let(:use_defaults) { true }
  let(:registry) { described_class.new(variables: variables, parent: parent, use_defaults: use_defaults) }

  context "with no parent, and using defaults" do
    it "raises error when not present" do
      expect{registry["not_exist"]}.to raise_error(Compute::Exceptions::UndefinedVariableError)
    end

    it "retrieves default variables" do
      expect(registry["true"]).to eq true
      expect(registry["false"]).to eq false
      expect(registry["pi"]).to eq Math::PI
      expect(registry["e"]).to eq Math::E
      expect(registry["i"]).to eq Complex(0,1)
    end

    it "can store and retrieve variables" do
      registry.register!("x", 4)
      expect(registry["x"]).to eq 4
    end
  end

  context "when not using defaults" do
    let(:use_defaults) { false }
    it "raises error when getting a default variable" do
      expect{registry["pi"]}.to raise_error(Compute::Exceptions::UndefinedVariableError)
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
      expect(registry["x"]).to eq 5
    end

    it "can shadow parent variables" do
      registry.register!("x", 11)

      expect(registry["x"]).to eq 11
      expect(parent_registry["x"]).to eq 5
    end
  end
end

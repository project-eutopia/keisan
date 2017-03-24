require "spec_helper"

RSpec.describe Compute::Functions::Registry do
  let(:functions) { {} }
  let(:parent) { nil }
  let(:use_defaults) { true }
  let(:registry) { described_class.new(functions: functions, parent: parent, use_defaults: use_defaults) }

  context "with no parent, and using defaults" do
    it "raises error when not present" do
      expect{registry["not_exist"]}.to raise_error(Compute::Exceptions::UndefinedFunctionError)
    end

    it "retrieves default methods" do
      expect{registry["sin"]}.not_to raise_error
      expect(registry["sin"].name).to eq "sin"
      expect(registry["sin"].call(nil, 0)).to eq 0
    end

    it "can store and retrieve methods" do
      registry.register!("test", Proc.new {|x,y| 2*x + y})
      expect(registry["test"].name).to eq "test"
      expect(registry["test"].call(nil, 3,5)).to eq 2*3 + 5
    end
  end

  context "when not using defaults" do
    let(:use_defaults) { false }
    it "raises error when getting a default function" do
      expect{registry["sin"]}.to raise_error(Compute::Exceptions::UndefinedFunctionError)
    end
  end

  context "with parent registry" do
    let(:parent_registry) do
      r = described_class.new
      r.register!("parent_function", Proc.new { 5 })
      r
    end

    let(:parent) { parent_registry }

    it "gets function from the parent" do
      expect(registry["parent_function"].name).to eq "parent_function"
      expect(registry["parent_function"].call(nil)).to eq 5
    end

    it "can shadow parent functions" do
      registry.register!("parent_function", Proc.new { 11 })

      expect(registry["parent_function"].name).to eq "parent_function"
      expect(registry["parent_function"].call(nil)).to eq 11

      expect(parent_registry["parent_function"].name).to eq "parent_function"
      expect(parent_registry["parent_function"].call(nil)).to eq 5
    end
  end
end

require "spec_helper"

RSpec.describe Compute::Functions::DefaultRegistry do
  it "contains correct functions" do
    registry = described_class.new

    expect(registry["sin"].name).to eq "sin"
    expect(registry["sin"].call(1)).to eq Math.sin(1)
  end
end

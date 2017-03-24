require "spec_helper"

RSpec.describe Compute::Variables::DefaultRegistry do
  let(:registry) { described_class.registry }

  it "contains correct variables" do
    expect(registry["true"]).to eq true
    expect(registry["false"]).to eq false
    expect(registry["pi"]).to eq Math::PI
    expect(registry["e"]).to eq Math::E
    expect(registry["i"]).to eq Complex(0,1)
  end

  it "is unmodifiable" do
    expect { registry.register!(:bad, false) }.to raise_error(Compute::Exceptions::UnmodifiableError)
  end
end

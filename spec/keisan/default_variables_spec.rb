require "spec_helper"

RSpec.describe Keisan::Variables::DefaultRegistry do
  let(:registry) { described_class.registry }

  it "contains correct variables" do
    expect(registry["PI"]).to eq Math::PI
    expect(registry["E"]).to eq Math::E
    expect(registry["I"]).to eq Complex(0,1)
  end

  it "is unmodifiable" do
    expect { registry.register!(:bad, false) }.to raise_error(Keisan::Exceptions::UnmodifiableError)
  end
end

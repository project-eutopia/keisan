require "spec_helper"

RSpec.describe Compute do
  it "has a version number" do
    expect(Compute::VERSION).not_to be nil
  end
end

require "spec_helper"

RSpec.describe Keisan::Functions::ProcFunction do
  it "can be initialized from a proc" do
    function = described_class.new("test", Proc.new {|x,y| x + 3*y})
    expect(function.name).to eq "test"
    expect(function.call(nil,2,6).value).to eq 2 + 3*6
  end

  it "must be a proc" do
    expect { described_class.new("test", 1) }.to raise_error(Keisan::Exceptions::InvalidFunctionError)
  end
end

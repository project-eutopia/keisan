require "spec_helper"

RSpec.describe Keisan::Functions::DefaultRegistry do
  let(:registry) { described_class.registry }
  it "contains correct functions" do
    expect(registry["sin"].name).to eq "sin"
    expect(registry["sin"].call(nil, 1).value).to eq Math.sin(1)
  end

  it "is unmodifiable" do
    expect { registry.register!(:bad, Proc.new { false }) }.to raise_error(Keisan::Exceptions::UnmodifiableError)
  end

  context "array methods" do
    it "works as expected" do
      expect(registry["min"].name).to eq "min"
      expect(registry["min"].call(nil, [-4, -1, 1, 2]).value).to eq -4

      expect(registry["max"].name).to eq "max"
      expect(registry["max"].call(nil, [-4, -1, 1, 2]).value).to eq 2

      expect(registry["size"].name).to eq "size"
      expect(registry["size"].call(nil, [-4, -1, 1, 2]).value).to eq 4

      expect(Keisan::Calculator.new.evaluate("a[size(a)-1]", a: [1, 3, 5, 7])).to eq 7
    end

    context "functional methods" do
      describe "#map" do
        it "maps the list to the given expression" do
          expect{Keisan::Calculator.new.evaluate("map(10, x, x**2)")}.to raise_error(Keisan::Exceptions::InvalidFunctionError)
          expect{Keisan::Calculator.new.evaluate("map([1,3,5], 4, x**2)")}.to raise_error(Keisan::Exceptions::InvalidFunctionError)
          expect(Keisan::Calculator.new.evaluate("map([1,3,5], x, x**2)")).to eq [1, 9, 25]
          expect(Keisan::Calculator.new.simplify("[1,3,5].map(x, y*x**2)")).to eq "[y,9*y,25*y]"
        end
      end
    end
  end

  context "random methods" do
    it "works as expected" do
      a = [2, 3, 6, 7]

      20.times do
        expect(0...4).to cover Keisan::Calculator.new.evaluate("rand(4)")
        expect(3...8).to cover Keisan::Calculator.new.evaluate("rand(3, 8)")
        expect(a).to include Keisan::Calculator.new.evaluate("sample(#{a})")
      end
    end

    it "uses correct Random object" do
      context1 = Keisan::Context.new(random: Random.new(1234))
      context2 = Keisan::Context.new(random: Random.new(1234))

      calc1 = Keisan::Calculator.new(context: context1)
      calc2 = Keisan::Calculator.new(context: context2)

      20.times do
        expect(calc1.evaluate("rand(100)")).to eq calc2.evaluate("rand(100)")
      end
    end
  end
end

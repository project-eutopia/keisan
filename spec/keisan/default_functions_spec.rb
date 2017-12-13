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

  context "transcendental methods" do
    it "works as expected" do
      expect(Keisan::Calculator.new.evaluate("exp(1)")).to eq Math::E
      expect(Keisan::Calculator.new.evaluate("exp(PI*I)").real).to eq -1
      expect(Keisan::Calculator.new.evaluate("exp(PI*I)").imag.abs).to be <= 1e-15
      expect(Keisan::Calculator.new.evaluate("log(I)")).to eq 1i*Math::PI/2

      expect(Keisan::Calculator.new.evaluate("sin(2*I)")).to eq (1i*Math::sinh(2))
      expect(Keisan::Calculator.new.evaluate("cos(-3*I)")).to eq Math::cosh(-3)
      expect(Keisan::Calculator.new.evaluate("tan(-I)")).to eq (1i*Math::tanh(-1))
      expect(Keisan::Calculator.new.evaluate("csc(2*I)")).to eq (1i*Math::sinh(2))**-1
      expect(Keisan::Calculator.new.evaluate("sec(-3*I)")).to eq Math::cosh(-3)**-1
      expect(Keisan::Calculator.new.evaluate("cot(-I)")).to eq (1i*Math::tanh(-1))**-1
    end
  end
end

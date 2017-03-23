require "spec_helper"

RSpec.describe SymbolicMath::AST::Builder do
  context "simple operations" do
    operations = {
      "1 + 2"               => 3,
      "7.5 - 3"             => 4.5,
      "2 + 3 * 5"           => 17,
      "8 / 5"               => Rational(8,5),
      "(1+2) * (3+4*(1+1))" => 33,
      "4**2 + 3 * 5"        => 31,
      "2 ** (1/2)"          => Math.sqrt(2)
    }

    operations.each do |operation, value|
      it "correctly builds the AST for #{operation}" do
        expect(described_class.new(string: operation).ast.value).to eq value
      end
    end
  end

  context "function" do
    it "properly parses" do
      expect(described_class.new(string: "sin(pi)").ast.value).to be_within(1e-10).of(0)
    end
  end

  context "with variables" do
    it "value raises error unless defined" do
      ast = described_class.new(string: "x + 1").ast
      expect { ast.value }.to raise_error(SymbolicMath::Exceptions::UndefinedVariableError)
    end

    it "fills in variable" do
      ast = described_class.new(string: "x + 1").ast
      context = SymbolicMath::Context.new
      context.register_variable!(:x, 3)
      expect(ast.value(context)).to eq 4
    end
  end
end

require "spec_helper"

RSpec.describe SymbolicMath::AST::Builder do
  context "simple operations" do
    it "correctly builds the AST" do
      operations = {
        "1 + 2"               => eq(3),
        "7.5 - 3"             => eq(4.5),
        "2 + 3 * 5"           => eq(17),
        "8 / 5"               => eq(Rational(8,5)),
        "(1+2) * (3+4*(1+1))" => eq(33),
        "4**2 + 3 * 5"        => eq(31),
        "2 ** (1/2)"          => eq(Math.sqrt(2)),
        "sin(pi)"             => be_within(1e-10).of(0)
      }

      operations.each do |operation, matcher|
        expect(described_class.new(string: operation).ast.value).to matcher
      end
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

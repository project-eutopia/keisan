require "spec_helper"

RSpec.describe Keisan do
  it "has the expected version number" do
    expect(Keisan::VERSION).to eq "0.8.0"
  end

  context "module methods" do
    after do
      # Want to reset the calculator internal to Keisan after each spec
      # so specs do not interfere
      Keisan.reset
    end

    describe "calculator" do
      it "has a calculator for use" do
        expect(Keisan.calculator).to be_a(Keisan::Calculator)
        Keisan.calculator.evaluate("x = 5")
        expect(Keisan["x"].value).to eq 5
      end

      it "is reset by #reset method" do
        Keisan["x = 5"]

        expect {
          Keisan.reset
        }.to change {
          Keisan["x"]
        }.from(Keisan::AST::Number.new(5)).to(Keisan::AST::Variable.new("x"))
      end
    end

    describe "evaluate" do
      it "evaluates the expression" do
        expect(Keisan.evaluate("1+2").value).to eq 3
        expect{Keisan.evaluate("x")}.to raise_error(Keisan::Exceptions::UndefinedVariableError)
      end
    end

    describe "ast" do
      it "returns the ast of the expression" do
        ast = Keisan.ast("1+x")
        expect(ast).to be_a(Keisan::AST::Plus)
        expect(ast.to_s).to eq "1+x"
      end
    end

    describe "simplify" do
      it "simplifies the expression" do
        expect(Keisan.simplify("0*x").value).to eq 0
        expect(Keisan.simplify("x")).to eq Keisan::AST::Variable.new("x")
      end
    end

    describe "[] method" do
      it "simplifies" do
        expect(Keisan["0*x"].value).to eq 0
        expect(Keisan["x"]).to eq Keisan::AST::Variable.new("x")
      end
    end
  end
end

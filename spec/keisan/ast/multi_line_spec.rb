require "spec_helper"

RSpec.describe Keisan::AST::MultiLine do
  describe "unbound_variables" do
    let(:context) { Keisan::Context.new }

    context "with empty context" do
      it "binds assigned variables" do
        ast = Keisan::AST.parse("x = 1; y = 2; x + y")
        expect(ast.unbound_variables(context)).to eq Set.new
      end

      it "recognizes when one variable is assigned to" do
        ast = Keisan::AST.parse("x = 3; y = 4; x + y")
        expect(ast.unbound_variables(context)).to eq Set.new
      end

      it "recognizes when one variable is assigned to and one is not" do
        ast = Keisan::AST.parse("x = 5; y = x + z; y")
        expect(ast.unbound_variables(context)).to eq Set.new(["y", "z"])
      end

      it "propagates unbound variable" do
        ast = Keisan::AST.parse("x = 1; y = x")
        expect(ast.unbound_variables(context)).to eq Set.new
      end
    end

    context "with one variable defined" do
      let(:context) {
        Keisan::Context.new.tap do |context|
          context.register_variable!("x", 1)
        end
      }

      it "handles case when y is defined" do
        ast = Keisan::AST.parse("y = 5; x + y")
        expect(ast.unbound_variables(context)).to eq Set.new
      end

      it "handles case when y is dependent on x" do
        ast = Keisan::AST.parse("y = x; x + y")
        expect(ast.unbound_variables(context)).to eq Set.new
      end

      it "propagates unbound variable" do
        ast = Keisan::AST.parse("y = x + z; x + y")
        expect(ast.unbound_variables(context)).to eq Set.new(["y", "z"])
      end

      it "propagates unbound variable" do
        ast = Keisan::AST.parse("x = 1; y = x")
        expect(ast.unbound_variables(context)).to eq Set.new
      end
    end
  end
end

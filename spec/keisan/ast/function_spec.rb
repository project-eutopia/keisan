require "spec_helper"

RSpec.describe Keisan::AST::Function do
  describe "is_constant?" do
    it "is false" do
      ast = Keisan::Calculator.new.ast("f(1)")
      expect(ast.is_constant?).to eq false
    end
  end
end

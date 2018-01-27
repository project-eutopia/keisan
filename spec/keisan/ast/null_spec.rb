require "spec_helper"

RSpec.describe Keisan::AST::Null do
  describe "logical operations" do
    it "can do == and != checks" do
      positive_equal     = described_class.new.equal     described_class.new
      negative_not_equal = described_class.new.not_equal described_class.new

      other_equal     = described_class.new.equal     Keisan::AST::Boolean.new(false)
      other_not_equal = described_class.new.not_equal Keisan::AST::Boolean.new(false)

      expect(positive_equal).to be_a(Keisan::AST::Boolean)
      expect(positive_equal.value).to eq true
      expect(negative_not_equal).to be_a(Keisan::AST::Boolean)
      expect(negative_not_equal.value).to eq false

      expect(other_equal).to be_a(Keisan::AST::LogicalEqual)
      expect(other_not_equal).to be_a(Keisan::AST::LogicalNotEqual)
    end
  end
end

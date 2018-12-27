require "spec_helper"

RSpec.describe Keisan::AST::Operator do
  shared_examples "an operator object" do |operator_class, arity, priority, associativity|
    it "has the given arity" do
      expect(operator_class.arity).to eq arity
    end

    it "has the given priority" do
      expect(operator_class.priority).to eq priority
    end

    it "has the given associativity" do
      expect(operator_class.associativity).to eq associativity
    end
  end

  it_behaves_like "an operator object", Keisan::AST::UnaryBitwiseNot,                     1, 100, :right
  it_behaves_like "an operator object", Keisan::Parsing::BitwiseNot.new,                  1, 100, :right
  it_behaves_like "an operator object", Keisan::AST::UnaryLogicalNot,                     1, 100, :right
  it_behaves_like "an operator object", Keisan::Parsing::LogicalNot.new,                  1, 100, :right
  it_behaves_like "an operator object", Keisan::AST::UnaryPlus,                           1, 100, :right
  it_behaves_like "an operator object", Keisan::Parsing::UnaryPlus.new,                   1, 100, :right
  it_behaves_like "an operator object", Keisan::AST::Exponent,                            2,  95, :right
  it_behaves_like "an operator object", Keisan::Parsing::Exponent.new,                    2,  95, :right
  it_behaves_like "an operator object", Keisan::AST::UnaryMinus,                          1,  90, :right
  it_behaves_like "an operator object", Keisan::Parsing::UnaryMinus.new,                  1,  90, :right
  it_behaves_like "an operator object", Keisan::AST::Times,                               2,  85,  :left
  it_behaves_like "an operator object", Keisan::Parsing::Times.new,                       2,  85,  :left
  it_behaves_like "an operator object", Keisan::AST::Times,                               2,  85,  :left
  it_behaves_like "an operator object", Keisan::Parsing::Times.new,                       2,  85,  :left
  it_behaves_like "an operator object", Keisan::Parsing::Divide.new,                      2,  85,  :left
  it_behaves_like "an operator object", Keisan::AST::Modulo,                              2,  85,  :left
  it_behaves_like "an operator object", Keisan::Parsing::Modulo.new,                      2,  85,  :left
  it_behaves_like "an operator object", Keisan::AST::Plus,                                2,  80,  :left
  it_behaves_like "an operator object", Keisan::Parsing::Plus.new,                        2,  80,  :left
  it_behaves_like "an operator object", Keisan::Parsing::Minus.new,                       2,  80,  :left
  it_behaves_like "an operator object", Keisan::AST::BitwiseLeftShift,                    2,  75,  :left
  it_behaves_like "an operator object", Keisan::Parsing::BitwiseLeftShift.new,            2,  75,  :left
  it_behaves_like "an operator object", Keisan::AST::BitwiseRightShift,                   2,  75,  :left
  it_behaves_like "an operator object", Keisan::Parsing::BitwiseRightShift.new,           2,  75,  :left
  it_behaves_like "an operator object", Keisan::AST::BitwiseAnd,                          2,  70,  :left
  it_behaves_like "an operator object", Keisan::Parsing::BitwiseAnd.new,                  2,  70,  :left
  it_behaves_like "an operator object", Keisan::AST::BitwiseXor,                          2,  65,  :left
  it_behaves_like "an operator object", Keisan::Parsing::BitwiseXor.new,                  2,  65,  :left
  it_behaves_like "an operator object", Keisan::AST::BitwiseOr,                           2,  65,  :left
  it_behaves_like "an operator object", Keisan::Parsing::BitwiseOr.new,                   2,  65,  :left
  it_behaves_like "an operator object", Keisan::AST::LogicalLessThan,                     2,  60,  :left
  it_behaves_like "an operator object", Keisan::Parsing::LogicalLessThan.new,             2,  60,  :left
  it_behaves_like "an operator object", Keisan::AST::LogicalLessThanOrEqualTo,            2,  60,  :left
  it_behaves_like "an operator object", Keisan::Parsing::LogicalLessThanOrEqualTo.new,    2,  60,  :left
  it_behaves_like "an operator object", Keisan::AST::LogicalGreaterThan,                  2,  60,  :left
  it_behaves_like "an operator object", Keisan::Parsing::LogicalGreaterThan.new,          2,  60,  :left
  it_behaves_like "an operator object", Keisan::AST::LogicalGreaterThanOrEqualTo,         2,  60,  :left
  it_behaves_like "an operator object", Keisan::Parsing::LogicalGreaterThanOrEqualTo.new, 2,  60,  :left
  it_behaves_like "an operator object", Keisan::AST::LogicalEqual,                        2,  55,  :none
  it_behaves_like "an operator object", Keisan::Parsing::LogicalEqual.new,                2,  55,  :none
  it_behaves_like "an operator object", Keisan::AST::LogicalNotEqual,                     2,  55,  :none
  it_behaves_like "an operator object", Keisan::Parsing::LogicalNotEqual.new,             2,  55,  :none
  it_behaves_like "an operator object", Keisan::AST::LogicalAnd,                          2,  50,  :left
  it_behaves_like "an operator object", Keisan::Parsing::LogicalAnd.new,                  2,  50,  :left
  it_behaves_like "an operator object", Keisan::AST::LogicalOr,                           2,  45,  :left
  it_behaves_like "an operator object", Keisan::Parsing::LogicalOr.new,                   2,  45,  :left
end

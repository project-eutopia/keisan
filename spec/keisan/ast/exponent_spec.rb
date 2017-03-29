require "spec_helper"

RSpec.describe Keisan::AST::Plus do
  it "is right associative" do
    ast = Keisan::AST.parse("x**y**z")
    expect(ast.to_s).to eq ("x**(y**z)")
  end
end

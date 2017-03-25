require "spec_helper"

RSpec.describe Keisan::AST::Node do
  describe "unbound_variables" do
    it "returns a Set of the undefined variable names" do
      ast = Keisan::AST::Builder.new(string: "pi").ast
      expect(ast.unbound_variables).to eq Set.new

      ast = Keisan::AST::Builder.new(string: "x").ast
      expect(ast.unbound_variables).to eq Set.new(["x"])

      ast = Keisan::AST::Builder.new(string: "x + y").ast
      expect(ast.unbound_variables).to eq Set.new(["x", "y"])

      context = Keisan::Context.new
      context.register_variable!("x", 0)
      expect(ast.unbound_variables(context)).to eq Set.new(["y"])
    end
  end

  describe "unbound_functions" do
    it "returns a Set of the undefined functions names" do
      ast = Keisan::AST::Builder.new(string: "sin").ast
      expect(ast.unbound_functions).to eq Set.new

      ast = Keisan::AST::Builder.new(string: "f(0)").ast
      expect(ast.unbound_functions).to eq Set.new(["f"])

      ast = Keisan::AST::Builder.new(string: "f(g(0), h())").ast
      expect(ast.unbound_functions).to eq Set.new(["f", "g", "h"])

      context = Keisan::Context.new
      context.register_function!("g", Proc.new { 1 })
      expect(ast.unbound_functions(context)).to eq Set.new(["f", "h"])
    end
  end
end

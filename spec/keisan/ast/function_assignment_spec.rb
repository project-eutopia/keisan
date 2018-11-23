require "spec_helper"

RSpec.describe Keisan::AST::FunctionAssignment do
  describe "unbound_variables" do
    it "shadows the appropriate enumerable method variables" do
      ast = Keisan::AST.parse("double(a) = a.map(x, 2*x)")
      expect(ast.unbound_variables).to eq Set["a"]

      ast = Keisan::AST.parse("triple(h) = h.map(k, v, [k, 3*v])")
      expect(ast.unbound_variables).to eq Set["h"]

      ast = Keisan::AST.parse("even(a) = a.filter(x, x % 2 == 0)")
      expect(ast.unbound_variables).to eq Set["a"]

      ast = Keisan::AST.parse("odd(h) = h.filter(k, v, v % 2 == 1)")
      expect(ast.unbound_variables).to eq Set["h"]

      ast = Keisan::AST.parse("include(a,x) = a.reduce(false, found, y, found || (x == y))")
      expect(ast.unbound_variables).to eq Set["a", "x"]

      ast = Keisan::AST.parse("include(h,x) = h.reduce(false, found, k, v, found || (v == x))")
      expect(ast.unbound_variables).to eq Set["h", "x"]
    end
  end
end

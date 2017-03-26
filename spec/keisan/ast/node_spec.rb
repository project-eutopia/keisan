require "spec_helper"

RSpec.describe Keisan::AST::Node do
  describe "unbound_variables" do
    it "returns a Set of the undefined variable names" do
      ast = Keisan::AST.parse("pi")
      expect(ast.unbound_variables).to eq Set.new

      ast = Keisan::AST.parse("x")
      expect(ast.unbound_variables).to eq Set.new(["x"])

      ast = Keisan::AST.parse("x + y")
      expect(ast.unbound_variables).to eq Set.new(["x", "y"])

      context = Keisan::Context.new
      context.register_variable!("x", 0)
      expect(ast.unbound_variables(context)).to eq Set.new(["y"])
    end
  end

  describe "unbound_functions" do
    it "returns a Set of the undefined functions names" do
      ast = Keisan::AST.parse("sin")
      expect(ast.unbound_functions).to eq Set.new

      ast = Keisan::AST.parse("f(0)")
      expect(ast.unbound_functions).to eq Set.new(["f"])

      ast = Keisan::AST.parse("f(g(0), h())")
      expect(ast.unbound_functions).to eq Set.new(["f", "g", "h"])

      context = Keisan::Context.new
      context.register_function!("g", Proc.new { 1 })
      expect(ast.unbound_functions(context)).to eq Set.new(["f", "h"])
    end
  end


  describe "==" do
    it "is true if the AST have the same structure and nodes" do
      s = "3 * (2 + f(sin(x), g(x)))"
      s_same = "3*(2+f(sin(x),g(x)))"
      s_diff_var = "3 * (2 + f(sin(x), g(y)))"
      s_diff_expr = "3 * (1 + 1 + f(sin(x), g(y)))"

      expect(Keisan::AST.parse(s_same)).to eq(Keisan::AST.parse(s))
      expect(Keisan::AST.parse(s_diff_var)).not_to eq(Keisan::AST.parse(s))
      expect(Keisan::AST.parse(s_diff_expr)).not_to eq(Keisan::AST.parse(s))

      expect(Keisan::AST.parse("1+2+3")).not_to eq(Keisan::AST.parse("1+(2+3)"))
    end
  end

  describe "deep_dup" do
    it "duplicates an AST recursively" do
      ast = Keisan::AST.parse("2 * (1 + f(sin(x), g(x)))")
      ast_dup = ast.deep_dup
      expect(ast_dup).not_to equal(ast)
      expect(ast_dup).to eq(ast)
    end
  end

  describe "simplify" do
    context "just numbers and arithmetic" do
      it "simplifies the expression" do
        ast = Keisan::AST.parse("1 + 3 + 5")
        ast_simple = ast.simplified
        expect(ast_simple).not_to eq(ast)
        expect(ast_simple).to be_a(Keisan::AST::Number)
        expect(ast_simple.value).to eq 9

        ast = Keisan::AST.parse("3 * (2**2+5)")
        ast_simple = ast.simplified
        expect(ast_simple).not_to eq(ast)
        expect(ast_simple).to be_a(Keisan::AST::Number)
        expect(ast_simple.value).to eq 27
      end
    end

    context "with prescribed variables" do
      it "fills the values in" do
        ast = Keisan::AST.parse("x**2 + y**2")
        ast_simple = ast.simplified(Keisan::Context.new.tap {|c|
          c.register_variable!("x", 3)
        })
        expect(ast_simple).to be_a(Keisan::AST::Plus)
        expect(ast_simple.to_s).to eq "9+(y**2)"

        ast_very_simple = ast.simplified(Keisan::Context.new.tap {|c|
          c.register_variable!("x", 3)
          c.register_variable!("y", 4)
        })
        expect(ast_very_simple).to be_a(Keisan::AST::Number)
        expect(ast_very_simple.value).to eq 25
      end
    end

    context "simplifying with zero" do
      it "sets the term to 0" do
        ast = Keisan::AST.parse("1 + 0*x")
        expect(ast.simplified).to be_a(Keisan::AST::Number)
        expect(ast.simplified.value).to eq 1

        ast = Keisan::AST.parse("12*x + (1-1)*y")
        expect(ast.simplified.to_s).to eq "12*x"
      end
    end

    context "simplifying with 1" do
      it "removes it from products" do
        ast = Keisan::AST.parse("15 + 1*x*((5-3)/2)")
        expect(ast.simplified.to_s).to eq "15+x"
      end

      it "is removed from top of exponents" do
        ast = Keisan::AST.parse("x + sin(y)**(5+x*y*(2-1-1)-4)")
        expect(ast.simplified.to_s).to eq "x+sin(y)"
      end
    end

    context "numbers and variables" do
      it "simplifies the expression, leaving the varible alone" do
        ast = Keisan::AST.parse("10 + x + 5 + y")
        ast_simple = ast.simplified
        expect(ast_simple).not_to eq(ast)
        expect(ast_simple).to be_a(Keisan::AST::Plus)
        expect(ast_simple.children[0].value).to eq 15
        expect(ast_simple.children[1].name).to eq "x"
        expect(ast_simple.children[2].name).to eq "y"
      end
    end

    context "function of just numbers" do
      it "evaluates the function" do
        ast = Keisan::AST.parse("12 + 2 * (sin(0) + 1)")
        ast_simple = ast.simplified
        expect(ast_simple).not_to eq(ast)
        expect(ast_simple).to be_a(Keisan::AST::Number)
        expect(ast_simple.value).to eq 14
      end
    end
  end

  describe "to_s" do
    context "arithmetic operations" do
      it "prints out the AST as a string expression, wrapping operators in brackets" do
        ast = Keisan::AST.parse("-15 + x**4 * 3 + sin(y)*(1+(-1))+f(z+1,w+1)[2]")
        expect(ast.to_s).to eq "-15+((x**4)*3)+(sin(y)*(1+-1))+f(z+1,w+1)[2]"
        expect(Keisan::AST.parse(ast.to_s)).to eq ast
      end
    end

    context "logical operations" do
      it "prints out the AST as a string expression, wrapping operators in brackets" do
        ast = Keisan::AST.parse("tan(x+2) < sin(y) || 3 == 5*2")
        expect(ast.to_s).to eq "(tan(x+2)<sin(y))||(3==(5*2))"
        expect(Keisan::AST.parse(ast.to_s)).to eq ast
      end
    end

    context "bitwise operations" do
      it "prints out the AST as a string expression, wrapping operators in brackets" do
        ast = Keisan::AST.parse("~2 & 3 | 5 ^ (6+8|9)")
        expect(ast.to_s).to eq "(~2&3)|(5^((6+8)|9))"
        expect(Keisan::AST.parse(ast.to_s)).to eq ast
      end
    end
  end
end

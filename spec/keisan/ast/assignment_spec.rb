require "spec_helper"

RSpec.describe Keisan::AST::Assignment do
  describe "evaluate" do
    context "nested groups" do
      it "evaluates to right hand side of assignment" do
        context = Keisan::Context.new
        ast = Keisan::AST.parse("5 + (x = 3)")

        expect(context.has_variable?("x")).to eq false
        evaluation = ast.evaluate(context)
        expect(context.variable("x").value).to eq 3
        expect(evaluation.value).to eq 8
      end

      it "evaluates to right hand side of assignment" do
        context = Keisan::Context.new
        ast = Keisan::AST.parse("g(x) = (f(x) = 2*x) ** 2")

        expect(context.has_function?("f")).to eq false
        expect(context.has_function?("g")).to eq false
        evaluation = ast.evaluate(context)
        expect(context.has_function?("f")).to eq true
        expect(context.has_function?("g")).to eq true

        expect(Keisan::AST.parse("f(3)").evaluate(context)).to eq Keisan::AST::Number.new(6)
        expect(Keisan::AST.parse("g(3)").evaluate(context)).to eq Keisan::AST::Number.new(36)
      end

      it "retains function as full expression" do
        calculator = Keisan::Calculator.new
        calculator.evaluate("f(x) = 3*x + 1")
        calculator.evaluate("g(x) = 2 + n + h(x)", n: 3, h: Proc.new{|x| 2**x})

        f = calculator.context.function("f")
        g = calculator.context.function("g")

        expect(calculator.evaluate("f(1)")).to eq 4
        expect(calculator.evaluate("f(2)")).to eq 7
        expect(calculator.evaluate("g(1)")).to eq 7
        expect(calculator.evaluate("g(2)")).to eq 9

        expect(f).to be_a(Keisan::Functions::ExpressionFunction)
        expect(g).to be_a(Keisan::Functions::ExpressionFunction)

        expect(f.expression).to be_a(Keisan::AST::Plus)
        expect(f.expression.children[0]).to be_a(Keisan::AST::Times)
        expect(f.expression.children[1]).to be_a(Keisan::AST::Number)
        expect(f.expression.children[1].value).to eq 1

        expect(f.expression.children[0].children[0]).to be_a(Keisan::AST::Number)
        expect(f.expression.children[0].children[0].value).to eq 3
        expect(f.expression.children[0].children[1]).to be_a(Keisan::AST::Variable)
        expect(f.expression.children[0].children[1].name).to eq "x"

        expect(g.expression).to be_a(Keisan::AST::Plus)
        expect(g.expression.children[0]).to be_a(Keisan::AST::Plus)
        expect(g.expression.children[0].children[0]).to be_a(Keisan::AST::Number)
        expect(g.expression.children[0].children[0].value).to eq 2
        expect(g.expression.children[0].children[1]).to be_a(Keisan::AST::Variable)
        expect(g.expression.children[0].children[1].name).to eq "n"
        expect(g.expression.children[1]).to be_a(Keisan::AST::Function)
        expect(g.expression.children[1].name).to eq "h"
        expect(g.expression.children[1].children.map(&:name)).to match_array(["x"])
      end
    end

    context "LHS is variable" do
      it "sets the variable to the RHS" do
        context = Keisan::Context.new
        ast = Keisan::AST.parse("x = 3")

        expect(context.has_variable?("x")).to eq false
        ast.evaluate(context)
        expect(context.variable("x").value).to eq 3
      end

      context "multiple assignments" do
        it "sets all variables" do
          context = Keisan::Context.new
          ast = Keisan::AST.parse("x = y = 5")

          expect(context.has_variable?("x")).to eq false
          expect(context.has_variable?("y")).to eq false
          ast.evaluate(context)
          expect(context.has_variable?("x")).to eq true
          expect(context.has_variable?("y")).to eq true

          expect(context.variable("x").value).to eq 5
          expect(context.variable("y").value).to eq 5
        end
      end
    end

    context "LHS is function" do
      context "simple function" do
        it "sets the function to the RHS" do
          context = Keisan::Context.new
          ast = Keisan::AST.parse("f(x) = x**2")

          expect(context.has_function?("f")).to eq false
          ast.evaluate(context)
          expect(context.has_function?("f")).to eq true

          function_eval = Keisan::AST.parse("f(3)").evaluate(context)
          expect(function_eval).to be_a(Keisan::AST::Number)
          expect(function_eval.value).to eq 9
        end
      end

      context "nested function" do
        it "sets the function to the RHS" do
          context = Keisan::Context.new
          ast = Keisan::AST.parse("f(x) = x**2")

          expect {
            ast.evaluate(context)
          }.to change {context.has_function?("f")}.from(false).to(true)

          ast = Keisan::AST.parse("g(x,y) = f(x) + y")

          expect {
            ast.evaluate(context)
          }.to change {context.has_function?("g")}.from(false).to(true)

          function_eval = Keisan::AST.parse("g(4, 5)").evaluate(context)
          expect(function_eval).to be_a(Keisan::AST::Number)
          expect(function_eval.value).to eq 4**2 + 5
        end
      end

      context "multiple assignments" do
        it "sets all functions" do
          context = Keisan::Context.new
          ast = Keisan::AST.parse("g(y, x) = f(x, y) = 2*x + y")

          expect(context.has_function?("f")).to eq false
          expect(context.has_function?("g")).to eq false
          ast.evaluate(context)
          expect(context.has_function?("f")).to eq true
          expect(context.has_function?("g")).to eq true

          function_eval = Keisan::AST.parse("f(4, 5)").evaluate(context)
          expect(function_eval).to be_a(Keisan::AST::Number)
          expect(function_eval.value).to eq 2*4 + 5

          function_eval = Keisan::AST.parse("g(4, 5)").evaluate(context)
          expect(function_eval).to be_a(Keisan::AST::Number)
          expect(function_eval.value).to eq 2*5 + 4
        end
      end

      context "recursive definition" do
        context "current context does not allow recursion" do
          it "raises an error" do
            context = Keisan::Context.new
            ast = Keisan::AST.parse("fact(n) = if ( n > 1, n*fact(n-1), 1 )")
            expect{ast.evaluate(context)}.to raise_error(Keisan::Exceptions::InvalidExpression)
          end
        end

        context "current context does allow recursion" do
          it "allows simple recursion" do
            context = Keisan::Context.new(allow_recursive: true)
            ast = Keisan::AST.parse("fact(n) = if ( n > 1, n*fact(n-1), 1 )")
            expect{ast.evaluate(context)}.not_to raise_error
            ast = Keisan::AST.parse("fact(4)")
            expect(ast.evaluate(context)).to be_a(Keisan::AST::Number)
            expect(ast.evaluate(context).value).to eq 4*3*2
          end

          it "allows mutual recursion" do
            context = Keisan::Context.new(allow_recursive: true)
            Keisan::AST.parse("even(n) = if ( n == 0, true, if ( n > 0, odd(n-1), odd(n+1) ) )").evaluate(context)
            Keisan::AST.parse("odd(n) = if ( n == 0, false, if ( n > 0, even(n-1), even(n+1) ) )").evaluate(context)

            ast = Keisan::AST.parse("odd(3)")
            expect(ast.evaluate(context)).to be_a(Keisan::AST::Boolean)
            expect(ast.evaluate(context).value).to eq true

            ast = Keisan::AST.parse("odd(-4)")
            expect(ast.evaluate(context)).to be_a(Keisan::AST::Boolean)
            expect(ast.evaluate(context).value).to eq false

            ast = Keisan::AST.parse("even(3)")
            expect(ast.evaluate(context)).to be_a(Keisan::AST::Boolean)
            expect(ast.evaluate(context).value).to eq false

            ast = Keisan::AST.parse("even(-4)")
            expect(ast.evaluate(context)).to be_a(Keisan::AST::Boolean)
            expect(ast.evaluate(context).value).to eq true
          end
        end
      end

      context "multi-line RHS" do
        it "evaluates the whole line" do
          calculator = Keisan::Calculator.new
          calculator.evaluate("f(x) = (12; 24)")
          expect(calculator.evaluate("f(3)").value).to eq 24
          calculator.evaluate("g(x) = (x = x + 1; x**2)")
          expect(calculator.evaluate("g(3)").value).to eq 16
        end
      end
    end

    context "function that uses previously defined variable" do
      it "shadows variables within function definitions" do
        context = Keisan::Context.new

        Keisan::AST.parse("x = 3 + 6").evaluate(context)
        evaluation = Keisan::AST.parse("2 * x").evaluate(context)
        expect(evaluation.value(context)).to eq 18

        Keisan::AST.parse("f(x) = x**2").evaluate(context)
        evaluation = Keisan::AST.parse("f(4)").evaluate(context)
        expect(evaluation.value(context)).to eq 16
      end
    end
  end
end

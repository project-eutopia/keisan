require "spec_helper"

RSpec.describe Keisan::AST::Assignment do
  describe "evaluate" do
    context "nested groups" do
      it "evaluates to right hand side of assignment" do
        context = Keisan::Context.new
        ast = Keisan::AST.parse("5 + (x = 3)")

        expect(context.has_variable?("x")).to eq false
        evaluation = ast.evaluate(context)
        expect(context.variable("x")).to eq 3
        expect(evaluation.value).to eq 8
      end
    end

    context "LHS is variable" do
      it "sets the variable to the RHS" do
        context = Keisan::Context.new
        ast = Keisan::AST.parse("x = 3")

        expect(context.has_variable?("x")).to eq false
        ast.evaluate(context)
        expect(context.variable("x")).to eq 3
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

          expect(context.variable("x")).to eq 5
          expect(context.variable("y")).to eq 5
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

          expect(context.has_function?("f")).to eq false
          ast.evaluate(context)
          expect(context.has_function?("f")).to eq true

          ast = Keisan::AST.parse("g(x,y) = f(x) + y")

          expect(context.has_function?("g")).to eq false
          ast.evaluate(context)
          expect(context.has_function?("g")).to eq true

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
            Keisan::AST.parse("even(n) = if ( n == 0, true, odd(n-1) )").evaluate(context)
            Keisan::AST.parse("odd(n) = if ( n == 0, false, even(n-1) )").evaluate(context)

            ast = Keisan::AST.parse("odd(3)")
            expect(ast.evaluate(context)).to be_a(Keisan::AST::Boolean)
            expect(ast.evaluate(context).value).to eq true

            ast = Keisan::AST.parse("even(3)")
            expect(ast.evaluate(context)).to be_a(Keisan::AST::Boolean)
            expect(ast.evaluate(context).value).to eq false
          end
        end
      end
    end
  end
end

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


    context "LHS is a list" do
      context "list assignment" do
        it "works when lhs is a list of variables and rhs is a list of same length" do
          context = Keisan::Context.new
          ast = Keisan::AST.parse("[a, b] = [1, 2]")

          expect(context.has_variable?("a")).to eq false
          expect(context.has_variable?("b")).to eq false
          ast.evaluate(context)
          expect(context.has_variable?("a")).to eq true
          expect(context.has_variable?("b")).to eq true

          expect(context.variable("a").value).to eq 1
          expect(context.variable("b").value).to eq 2
        end

        it "can do compound operators" do
          context = Keisan::Context.new
          Keisan::AST.parse("x = 3").evaluate(context)

          expect(context.has_variable?("x")).to eq true
          expect(context.has_variable?("y")).to eq false
          expect(context.variable("x").value).to eq 3

          ast = Keisan::AST.parse("[x, y] = [4, 5]")

          ast.evaluate(context)

          expect(context.has_variable?("x")).to eq true
          expect(context.has_variable?("y")).to eq true
          expect(context.variable("x").value).to eq 4
          expect(context.variable("y").value).to eq 5
        end

        it "can do compound operators" do
          context = Keisan::Context.new
          Keisan::AST.parse("x = [1, 2]").evaluate(context)
          Keisan::AST.parse("y = {'a': 4, 'b': 5}").evaluate(context)

          ast = Keisan::AST.parse("[x[0], y['b']] += [10, x[1]]")

          ast.evaluate(context)

          expect(context.has_variable?("x")).to eq true
          expect(context.has_variable?("y")).to eq true
          expect(context.variable("x").value).to eq([11, 2])
          expect(context.variable("y").value).to eq({'a' => 4, 'b' => 7})
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

    context "compound operator/assignments" do
      context "when simple variable on lhs" do
        it "raises an error for new variables" do
          calculator = Keisan::Calculator.new
          expect{calculator.evaluate("x += 1")}.to raise_error(Keisan::Exceptions::InvalidExpression)
        end

        it "can do compound operations" do
          calculator = Keisan::Calculator.new
          calculator.evaluate("x = 1")

          expect{calculator.evaluate("x += 2")}.to change{calculator.evaluate("x").value}.from(1).to(3)
          expect{calculator.evaluate("x -= 1")}.to change{calculator.evaluate("x").value}.from(3).to(2)
          expect{calculator.evaluate("x *= 6")}.to change{calculator.evaluate("x").value}.from(2).to(12)
          expect{calculator.evaluate("x /= 2")}.to change{calculator.evaluate("x").value}.from(12).to(6)
          expect{calculator.evaluate("x **= 2")}.to change{calculator.evaluate("x").value}.from(6).to(36)
          expect{calculator.evaluate("x %= 5")}.to change{calculator.evaluate("x").value}.from(36).to(1)
          expect{calculator.evaluate("x |= 4")}.to change{calculator.evaluate("x").value}.from(1).to(5)
          expect{calculator.evaluate("x ^= 3")}.to change{calculator.evaluate("x").value}.from(5).to(6)
          expect{calculator.evaluate("x &= 12")}.to change{calculator.evaluate("x").value}.from(6).to(4)
          expect{calculator.evaluate("x <<= 2")}.to change{calculator.evaluate("x").value}.from(4).to(16)
          expect{calculator.evaluate("x >>= 3")}.to change{calculator.evaluate("x").value}.from(16).to(2)
        end

        it "can do ||= operation" do
          calculator = Keisan::Calculator.new

          # Not yet defined, it simply sets it
          calculator.evaluate("x ||= 10")
          expect(calculator.evaluate("x").value).to eq 10

          # Already defined and truthy, it does nothing
          expect{calculator.evaluate("x ||= 20")}.not_to change{calculator.evaluate("x").value}

          # Already defined and falsey, it changes the value
          calculator.evaluate("x = false")
          expect{calculator.evaluate("x ||= 30")}.to change{calculator.evaluate("x").value}.from(false).to(30)
          calculator.evaluate("x = nil")
          expect{calculator.evaluate("x ||= 40")}.to change{calculator.evaluate("x").value}.from(nil).to(40)
        end

        it "can do &&= operation" do
          calculator = Keisan::Calculator.new

          # Not yet defined, it short-circuits and sets it to nil
          calculator.evaluate("x &&= (y = 10)")
          expect(calculator.evaluate("x").value).to eq nil
          expect(calculator.context.has_variable?("y")).to eq false

          # Already defined and truthy, it changes to the RHS
          calculator.evaluate("x = 10")
          expect{calculator.evaluate("x &&= 20")}.to change{calculator.evaluate("x").value}.from(10).to(20)

          # Already defined and falsey, it short-circuits and leaves untouched
          calculator.evaluate("x = false")
          expect{calculator.evaluate("x &&= (y = 10)")}.not_to change{calculator.context.has_variable?("y")}.from(false)
          expect(calculator.evaluate("x").value).to eq false
          calculator.evaluate("x = nil")
          expect{calculator.evaluate("x &&= (y = 10)")}.not_to change{calculator.context.has_variable?("y")}.from(false)
          expect(calculator.evaluate("x").value).to eq nil
        end
      end

      context "when list, so accessing cells stored within variable" do
        it "can modify elements" do
          calculator = Keisan::Calculator.new
          calculator.evaluate("ll = [[1,2],[3,4]]")
          calculator.evaluate("ll[0*0][0] += ll[1][1*1]")
          expect(calculator.evaluate("ll").value).to eq [[5,2],[3,4]]

          calculator.evaluate("a = [1,2,3]")
          calculator.evaluate("a[1] += 10")
          calculator.evaluate("a[1] *= 2a[0]")
          calculator.evaluate("a[1] &= 10")
          expect(calculator.evaluate("a").value).to eq [1,8,3]

          calculator.evaluate("h = {'a': 2, 'b': 5}")
          calculator.evaluate("h['a'] += 2*h['b']")
          calculator.evaluate("h['a'] *= 2")
          calculator.evaluate("h['a'] &= 10")
          expect(calculator.evaluate("h").value).to eq({"a" => 8, "b" => 5})
        end

        it "can do ||= operation" do
          calculator = Keisan::Calculator.new

          calculator.evaluate("a = [nil,false,0]")
          calculator.evaluate("a[0] ||= 1")
          calculator.evaluate("a[1] ||= 2")
          calculator.evaluate("a[2] ||= 3")
          expect(calculator.evaluate("a").value).to eq [1,2,0]

          calculator.evaluate("h = {'a': nil, 'b': false, 'c': 0}")
          calculator.evaluate("h['a'] ||= 1")
          calculator.evaluate("h['b'] ||= 2")
          calculator.evaluate("h['c'] ||= 3")
          expect(calculator.evaluate("h").value).to eq({"a" => 1, "b" => 2, "c" => 0})
        end

        it "can do &&= operation" do
          calculator = Keisan::Calculator.new

          calculator.evaluate("a = [nil,false,0]")
          calculator.evaluate("a[0] &&= 1")
          calculator.evaluate("a[1] &&= 2")
          calculator.evaluate("a[2] &&= 3")
          expect(calculator.evaluate("a").value).to eq [nil,false,3]

          calculator.evaluate("h = {'a': nil, 'b': false, 'c': 0}")
          calculator.evaluate("h['a'] &&= 1")
          calculator.evaluate("h['b'] &&= 2")
          calculator.evaluate("h['c'] &&= 3")
          expect(calculator.evaluate("h").value).to eq({"a" => nil, "b" => false, "c" => 3})
        end
      end

      context "when function" do
        it "raises an error" do
          calculator = Keisan::Calculator.new
          calculator.evaluate("f(x) = 1")
          expect{calculator.evaluate("f(x) += 2")}.to raise_error(Keisan::Exceptions::InvalidExpression)
        end
      end
    end
  end

  describe "unbound_variables" do
    let(:context) { Keisan::Context.new }

    context "single-line" do
      context "empty context" do
        it "assigns to itself" do
          ast = Keisan::AST.parse("x = x")
          expect(ast.unbound_variables(context)).to eq Set.new(["x"])
        end

        it "has assigned variables bound" do
          ast = Keisan::AST.parse("x = 5")
          expect(ast.unbound_variables(context)).to eq Set.new
        end

        it "has variable set to unknown unbound" do
          ast = Keisan::AST.parse("x = y")
          expect(ast.unbound_variables(context)).to eq Set.new(["x", "y"])
        end
      end

      context "with one defintion in context" do
        let(:context) {
          Keisan::Context.new.tap do |context|
            context.register_variable!("x", 1)
          end
        }

        it "can self-assign" do
          ast = Keisan::AST.parse("x = x")
          expect(ast.unbound_variables(context)).to eq Set.new
        end

        it "re-assigns" do
          ast = Keisan::AST.parse("x = 5")
          expect(ast.unbound_variables(context)).to eq Set.new
        end

        it "has assigned variables bound" do
          ast = Keisan::AST.parse("y = x")
          expect(ast.unbound_variables(context)).to eq Set.new
        end

        it "has assigned variables bound" do
          ast = Keisan::AST.parse("y = x + z")
          expect(ast.unbound_variables(context)).to eq Set.new(["y", "z"])
        end
      end
    end

    context "multi-line" do
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
    end
  end
end

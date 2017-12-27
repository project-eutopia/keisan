require "spec_helper"

RSpec.describe Keisan::Parser do
  it "either string or tokens" do
    expect{described_class.new}.to raise_error Keisan::Exceptions::InternalError
  end

  describe "ast" do
    it "returns the AST representation of the string" do
      parser = described_class.new(string: "1+x")
      ast = parser.ast
      expect(ast).to be_a(Keisan::AST::Plus)
      expect(ast.children[0].value).to eq 1
      expect(ast.children[1].name).to eq "x"
    end
  end

  describe "invalid expressions" do
    it "raises an error" do
      expect{described_class.new(string: "x..size()")}.to raise_error Keisan::Exceptions::ParseError
    end
  end

  describe "components" do
    context "simple operations" do
      it "has correct components" do
        parser = described_class.new(string: "1 + 2 - 3 * 4 / x")

        expect(parser.components.map(&:class)).to match_array([
          Keisan::Parsing::Number,
          Keisan::Parsing::Plus,
          Keisan::Parsing::Number,
          Keisan::Parsing::Minus,
          Keisan::Parsing::Number,
          Keisan::Parsing::Times,
          Keisan::Parsing::Number,
          Keisan::Parsing::Divide,
          Keisan::Parsing::Variable
        ])

        expect(parser.components[0].value).to eq 1
        expect(parser.components[2].value).to eq 2
        expect(parser.components[4].value).to eq 3
        expect(parser.components[6].value).to eq 4
        expect(parser.components[8].name).to eq "x"
      end
    end

    context "has unary operators" do
      it "correctly picks them up" do
        parser = described_class.new(string: "!2 * -x")

        expect(parser.components.map(&:class)).to match_array([
          Keisan::Parsing::LogicalNot,
          Keisan::Parsing::Number,
          Keisan::Parsing::Times,
          Keisan::Parsing::UnaryMinus,
          Keisan::Parsing::Variable
        ])

        expect(parser.components[1].value).to eq 2
        expect(parser.components[4].name).to eq "x"
      end

      it "handles multiple unary operators" do
        parser = described_class.new(string: "~15+!~-z")

        expect(parser.components.map(&:class)).to match_array([
          Keisan::Parsing::BitwiseNot,
          Keisan::Parsing::Number,
          Keisan::Parsing::Plus,
          Keisan::Parsing::LogicalNot,
          Keisan::Parsing::BitwiseNot,
          Keisan::Parsing::UnaryMinus,
          Keisan::Parsing::Variable
        ])

        expect(parser.components[1].value).to eq 15
        expect(parser.components[6].name).to eq "z"
      end
    end

    context "has brackets" do
      it "uses Parsing::Group to contain the element" do
        parser = described_class.new(string: "2 * (3 + 5)")

        expect(parser.components.map(&:class)).to match_array([
          Keisan::Parsing::Number,
          Keisan::Parsing::Times,
          Keisan::Parsing::RoundGroup
        ])

        expect(parser.components[0].value).to eq 2

        group = parser.components[2]
        expect(group.components.map(&:class)).to match_array([
          Keisan::Parsing::Number,
          Keisan::Parsing::Plus,
          Keisan::Parsing::Number
        ])

        expect(group.components[0].value).to eq 3
        expect(group.components[2].value).to eq 5
      end

      context "curly bracket multilines" do
        it "parses correctly" do
          parser = described_class.new(string: "f(x) = {a = 1; x+a}")
          expect(parser.components.map(&:class)).to match_array([
            Keisan::Parsing::Function,
            Keisan::Parsing::Assignment,
            Keisan::Parsing::CurlyGroup
          ])
        end
      end

      context "square bracket indexing" do
        it "handles simple array" do
          parser = described_class.new(string: "[1,2]")
          expect(parser.components.map(&:class)).to match_array([
            Keisan::Parsing::List
          ])

          arguments = parser.components[0].arguments
          expect(arguments.count).to eq 2
          expect(arguments[0].components.map(&:class)).to match_array([Keisan::Parsing::Number])
          expect(arguments[0].components[0].value).to eq 1
          expect(arguments[1].components.map(&:class)).to match_array([Keisan::Parsing::Number])
          expect(arguments[1].components[0].value).to eq 2
        end

        it "handles indexing an array" do
          parser = described_class.new(string: "[1,2,x][1+y]")
          expect(parser.components.map(&:class)).to match_array([
            Keisan::Parsing::List,
            Keisan::Parsing::Indexing
          ])

          arguments = parser.components[0].arguments
          expect(arguments.count).to eq 3
          expect(arguments[0].components.map(&:class)).to match_array([Keisan::Parsing::Number])
          expect(arguments[0].components[0].value).to eq 1
          expect(arguments[1].components.map(&:class)).to match_array([Keisan::Parsing::Number])
          expect(arguments[1].components[0].value).to eq 2
          expect(arguments[2].components.map(&:class)).to match_array([Keisan::Parsing::Variable])
          expect(arguments[2].components[0].name).to eq "x"

          arguments = parser.components[1].arguments
          expect(arguments.count).to eq 1
          expect(arguments[0].components.map(&:class)).to match_array([
            Keisan::Parsing::Number,
            Keisan::Parsing::Plus,
            Keisan::Parsing::Variable
          ])
          expect(arguments[0].components[0].value).to eq 1
          expect(arguments[0].components[2].name).to eq "y"
        end

        it "handles indexing a variable" do
          parser = described_class.new(string: "~a[1,2]")
          expect(parser.components.map(&:class)).to match_array([
            Keisan::Parsing::BitwiseNot,
            Keisan::Parsing::Variable,
            Keisan::Parsing::Indexing
          ])

          expect(parser.components[1].name).to eq "a"
          arguments = parser.components[2].arguments
          expect(arguments[0].components.map(&:class)).to match_array([Keisan::Parsing::Number])
          expect(arguments[0].components[0].value).to eq 1
          expect(arguments[1].components.map(&:class)).to match_array([Keisan::Parsing::Number])
          expect(arguments[1].components[0].value).to eq 2
        end

        it "handles indexing a function call" do
          parser = described_class.new(string: "a(x)[1,2]")
          expect(parser.components.map(&:class)).to match_array([
            Keisan::Parsing::Function,
            Keisan::Parsing::Indexing
          ])

          expect(parser.components[0].name).to eq "a"
          expect(parser.components[0].arguments.count).to eq 1
          expect(parser.components[0].arguments[0].components.map(&:class)).to match_array([Keisan::Parsing::Variable])
          expect(parser.components[0].arguments[0].components[0].name).to eq "x"

          arguments = parser.components[1].arguments
          expect(arguments[0].components.map(&:class)).to match_array([Keisan::Parsing::Number])
          expect(arguments[0].components[0].value).to eq 1
          expect(arguments[1].components.map(&:class)).to match_array([Keisan::Parsing::Number])
          expect(arguments[1].components[0].value).to eq 2
        end

        it "handles complicated case" do
          parser = described_class.new(string: "~func(x,y)[2][n-1,m+1]")

          expect(parser.components.map(&:class)).to match_array([
            Keisan::Parsing::BitwiseNot,
            Keisan::Parsing::Function,
            Keisan::Parsing::Indexing,
            Keisan::Parsing::Indexing
          ])
        end
      end
    end

    context "has nested brackets" do
      it "uses Parsing::Group to contain the element" do
        parser = described_class.new(string: "x ** (y * (1 + z))")

        expect(parser.components.map(&:class)).to match_array([
          Keisan::Parsing::Variable,
          Keisan::Parsing::Exponent,
          Keisan::Parsing::RoundGroup
        ])

        expect(parser.components[0].name).to eq "x"

        group = parser.components[2]
        expect(group.components.map(&:class)).to match_array([
          Keisan::Parsing::Variable,
          Keisan::Parsing::Times,
          Keisan::Parsing::RoundGroup
        ])

        expect(group.components[0].name).to eq "y"

        group = group.components[2]
        expect(group.components.map(&:class)).to match_array([
          Keisan::Parsing::Number,
          Keisan::Parsing::Plus,
          Keisan::Parsing::Variable
        ])

        expect(group.components[0].value).to eq 1
        expect(group.components[2].name).to eq "z"
      end
    end

    context "has function call" do
      describe "no arguments" do
        it "has no arguments" do
          parser = described_class.new(string: "f()")
          expect(parser.components.map(&:class)).to match_array([
            Keisan::Parsing::Function
          ])

          fn = parser.components.first
          expect(fn.arguments).to match_array([])
        end
      end

      describe "postfix notation" do
        it "parses with or without brackets" do
          parser = described_class.new(string: "a.size")
          expect(parser.components.map(&:class)).to match_array([
            Keisan::Parsing::Variable,
            Keisan::Parsing::DotWord
          ])

          parser = described_class.new(string: "a.size()")
          expect(parser.components.map(&:class)).to match_array([
            Keisan::Parsing::Variable,
            Keisan::Parsing::DotOperator
          ])

          parser = described_class.new(string: "a.size+nil")
          expect(parser.components.map(&:class)).to match_array([
            Keisan::Parsing::Variable,
            Keisan::Parsing::DotWord,
            Keisan::Parsing::Plus,
            Keisan::Parsing::Null
          ])
        end
      end

      describe "one argument" do
        it "has one argument" do
          parser = described_class.new(string: "f(x+1)")
          expect(parser.components.map(&:class)).to match_array([
            Keisan::Parsing::Function
          ])

          fn = parser.components.first
          expect(fn.arguments.count).to eq 1

          expect(fn.arguments.first.components.map(&:class)).to match_array([
            Keisan::Parsing::Variable,
            Keisan::Parsing::Plus,
            Keisan::Parsing::Number
          ])
          expect(fn.arguments.first.components[0].name).to eq "x"
          expect(fn.arguments.first.components[2].value).to eq 1
        end
      end

      describe "two arguments" do
        it "has two arguments" do
          parser = described_class.new(string: "f(x+1, y-1)")
          expect(parser.components.map(&:class)).to match_array([
            Keisan::Parsing::Function
          ])

          fn = parser.components.first
          expect(fn.arguments.count).to eq 2

          expect(fn.arguments.first.components.map(&:class)).to match_array([
            Keisan::Parsing::Variable,
            Keisan::Parsing::Plus,
            Keisan::Parsing::Number
          ])
          expect(fn.arguments.first.components[0].name).to eq "x"
          expect(fn.arguments.first.components[2].value).to eq 1

          expect(fn.arguments.last.components.map(&:class)).to match_array([
            Keisan::Parsing::Variable,
            Keisan::Parsing::Minus,
            Keisan::Parsing::Number
          ])
          expect(fn.arguments.last.components[0].name).to eq "y"
          expect(fn.arguments.last.components[2].value).to eq 1
        end
      end

      it "contains the correct arguments" do
        parser = described_class.new(string: "1 + atan2(x + 1, y - 1)")

        expect(parser.components.map(&:class)).to match_array([
          Keisan::Parsing::Number,
          Keisan::Parsing::Plus,
          Keisan::Parsing::Function
        ])

        expect(parser.components[0].value).to eq 1
        expect(parser.components[2].name).to eq "atan2"

        arguments = parser.components[2].arguments
        expect(arguments.count).to eq 2

        expect(arguments.all? {|argument| argument.is_a?(Keisan::Parsing::Argument)}).to be true

        expect(arguments.first.components.map(&:class)).to match_array([
          Keisan::Parsing::Variable,
          Keisan::Parsing::Plus,
          Keisan::Parsing::Number
        ])
        expect(arguments.first.components[0].name).to eq "x"
        expect(arguments.first.components[2].value).to eq 1

        expect(arguments.last.components.map(&:class)).to match_array([
          Keisan::Parsing::Variable,
          Keisan::Parsing::Minus,
          Keisan::Parsing::Number
        ])
        expect(arguments.last.components[0].name).to eq "y"
        expect(arguments.last.components[2].value).to eq 1
      end
    end

    context "bitwise operators" do
      it "parses correctly" do
        parser = described_class.new(string: "~~~~9 & 8 | (~16 + 1) ^ 4")

        expect(parser.components.map(&:class)).to match_array([
          Keisan::Parsing::Number,
          Keisan::Parsing::BitwiseAnd,
          Keisan::Parsing::Number,
          Keisan::Parsing::BitwiseOr,
          Keisan::Parsing::RoundGroup,
          Keisan::Parsing::BitwiseXor,
          Keisan::Parsing::Number
        ])

        expect(parser.components[0].value).to eq 9
        expect(parser.components[2].value).to eq 8
        expect(parser.components[6].value).to eq 4

        group = parser.components[4]
        expect(group.components.map(&:class)).to match_array([
          Keisan::Parsing::BitwiseNot,
          Keisan::Parsing::Number,
          Keisan::Parsing::Plus,
          Keisan::Parsing::Number
        ])

        expect(group.components[1].value).to eq 16
        expect(group.components[3].value).to eq 1
      end
    end

    context "logical operators" do
      it "parses correctly" do
        parser = described_class.new(string: "true && !!!false || (!false || 2 > 0) && 5 >= 5")

        expect(parser.components.map(&:class)).to match_array([
          Keisan::Parsing::Boolean,
          Keisan::Parsing::LogicalAnd,
          Keisan::Parsing::LogicalNot,
          Keisan::Parsing::Boolean,
          Keisan::Parsing::LogicalOr,
          Keisan::Parsing::RoundGroup,
          Keisan::Parsing::LogicalAnd,
          Keisan::Parsing::Number,
          Keisan::Parsing::LogicalGreaterThanOrEqualTo,
          Keisan::Parsing::Number
        ])

        expect(parser.components[0].value).to eq true
        expect(parser.components[3].value).to eq false
        expect(parser.components[7].value).to eq 5
        expect(parser.components[9].value).to eq 5

        group = parser.components[5]
        expect(group.components.map(&:class)).to match_array([
          Keisan::Parsing::LogicalNot,
          Keisan::Parsing::Boolean,
          Keisan::Parsing::LogicalOr,
          Keisan::Parsing::Number,
          Keisan::Parsing::LogicalGreaterThan,
          Keisan::Parsing::Number
        ])

        expect(group.components[1].value).to eq false
        expect(group.components[3].value).to eq 2
        expect(group.components[5].value).to eq 0
      end

      it "handles equality operators" do
        parser = described_class.new(string: "4 == 5 && x != y")

        expect(parser.components.map(&:class)).to match_array([
          Keisan::Parsing::Number,
          Keisan::Parsing::LogicalEqual,
          Keisan::Parsing::Number,
          Keisan::Parsing::LogicalAnd,
          Keisan::Parsing::Variable,
          Keisan::Parsing::LogicalNotEqual,
          Keisan::Parsing::Variable
        ])

        expect(parser.components[0].value).to eq 4
        expect(parser.components[2].value).to eq 5
        expect(parser.components[4].name).to eq "x"
        expect(parser.components[6].name).to eq "y"
      end
    end

    context "combination" do
      it "parses correctly" do
        parser = described_class.new(string: "-sin(x ** (2+1)) + (a + b*z) / (c + d*z)")

        expect(parser.components.map(&:class)).to match_array([
          Keisan::Parsing::UnaryMinus,
          Keisan::Parsing::Function,
          Keisan::Parsing::Plus,
          Keisan::Parsing::RoundGroup,
          Keisan::Parsing::Divide,
          Keisan::Parsing::RoundGroup
        ])

        function = parser.components[1]
        expect(function.name).to eq "sin"
        expect(function.arguments.count).to eq 1
        argument = function.arguments.first

        expect(argument.components.map(&:class)).to match_array([
          Keisan::Parsing::Variable,
          Keisan::Parsing::Exponent,
          Keisan::Parsing::RoundGroup
        ])

        expect(argument.components[0].name).to eq "x"
        group = argument.components[2]

        expect(group.components.map(&:class)).to match_array([
          Keisan::Parsing::Number,
          Keisan::Parsing::Plus,
          Keisan::Parsing::Number
        ])

        expect(group.components[0].value).to eq 2
        expect(group.components[2].value).to eq 1

        numerator = parser.components[3]
        denominator = parser.components[5]

        expect(numerator.components.map(&:class)).to match_array([
          Keisan::Parsing::Variable,
          Keisan::Parsing::Plus,
          Keisan::Parsing::Variable,
          Keisan::Parsing::Times,
          Keisan::Parsing::Variable
        ])
        expect(denominator.components.map(&:class)).to match_array([
          Keisan::Parsing::Variable,
          Keisan::Parsing::Plus,
          Keisan::Parsing::Variable,
          Keisan::Parsing::Times,
          Keisan::Parsing::Variable
        ])

        expect(numerator.components[0].name).to eq "a"
        expect(numerator.components[2].name).to eq "b"
        expect(numerator.components[4].name).to eq "z"
        expect(denominator.components[0].name).to eq "c"
        expect(denominator.components[2].name).to eq "d"
        expect(denominator.components[4].name).to eq "z"
      end
    end

    context "string" do
      it "parses correctly" do
        parser = described_class.new(string: "'this is a ' + \"test\"")

        expect(parser.components.map(&:class)).to match_array([
          Keisan::Parsing::String,
          Keisan::Parsing::Plus,
          Keisan::Parsing::String
        ])

        expect(parser.components[0].value).to eq "this is a "
        expect(parser.components[2].value).to eq "test"
      end
    end

    context "dot operator" do
      it "parses correctly" do
        parser = described_class.new(string: "[1,2,3].apply(i,1+2).abs")

        expect(parser.components.map(&:class)).to match_array([
          Keisan::Parsing::List,
          Keisan::Parsing::DotOperator,
          Keisan::Parsing::DotWord
        ])

        # list
        list_args = parser.components[0].arguments
        expect(list_args[0].components.count).to eq 1
        expect(list_args[0].components[0].value).to eq 1
        expect(list_args[1].components.count).to eq 1
        expect(list_args[1].components[0].value).to eq 2
        expect(list_args[2].components.count).to eq 1
        expect(list_args[2].components[0].value).to eq 3

        # apply operator
        dot_operator = parser.components[1]
        expect(dot_operator.name).to eq "apply"
        expect(dot_operator.arguments.count).to eq 2

        arg1 = dot_operator.arguments[0]
        arg2 = dot_operator.arguments[1]

        expect(arg1.components.count).to eq 1
        expect(arg1.components[0].name).to eq "i"

        expect(arg2.components.count).to eq 3
        expect(arg2.components[0].value).to eq 1
        expect(arg2.components[2].value).to eq 2

        # abs operator
        dot_operator = parser.components[2]
        expect(dot_operator.name).to eq "abs"
      end

      it "back-to-back without braces" do
        parser = described_class.new(string: "a.b.c")

        expect(parser.components.map(&:class)).to match_array([
          Keisan::Parsing::Variable,
          Keisan::Parsing::DotWord,
          Keisan::Parsing::DotWord
        ])

        expect(parser.components[0].name).to eq "a"
        expect(parser.components[1].name).to eq "b"
        expect(parser.components[2].name).to eq "c"
      end
    end

    context "assignment" do
      it "parses correctly" do
        parser = described_class.new(string: "x = y = 5")

        expect(parser.components.map(&:class)).to eq([
          Keisan::Parsing::Variable,
          Keisan::Parsing::Assignment,
          Keisan::Parsing::Variable,
          Keisan::Parsing::Assignment,
          Keisan::Parsing::Number
        ])

        expect(parser.components[0].name).to eq "x"
        expect(parser.components[2].name).to eq "y"
        expect(parser.components[4].value).to eq 5
      end
    end

    context "multiline" do
      it "recognizes semi-colons and newlines as line separators" do
        parser = described_class.new(string: "1 \n x; 3 ")

        expect(parser.components.map(&:class)).to eq([
          Keisan::Parsing::Number,
          Keisan::Parsing::LineSeparator,
          Keisan::Parsing::Variable,
          Keisan::Parsing::LineSeparator,
          Keisan::Parsing::Number
        ])

        expect(parser.components[0].value).to eq 1
        expect(parser.components[2].name).to eq "x"
        expect(parser.components[4].value).to eq 3
      end

      it "works okay inside brackets too" do
        parser = described_class.new(string: "10 + (1; x)")
        expect(parser.components.map(&:class)).to eq([
          Keisan::Parsing::Number,
          Keisan::Parsing::Plus,
          Keisan::Parsing::RoundGroup
        ])

        expect(parser.components[2].components.map(&:class)).to eq([
          Keisan::Parsing::Number,
          Keisan::Parsing::LineSeparator,
          Keisan::Parsing::Variable
        ])

        parser = described_class.new(string: "f(x;,\n g(a,1;b))")
        expect(parser.components.map(&:class)).to eq([Keisan::Parsing::Function])

        expect(parser.components[0].arguments[0].components.map(&:class)).to eq([
          Keisan::Parsing::Variable,
          Keisan::Parsing::LineSeparator
        ])
        expect(parser.components[0].arguments[1].components.map(&:class)).to eq([
          Keisan::Parsing::LineSeparator,
          Keisan::Parsing::Function
        ])

        expect(parser.components[0].arguments[1].components[1].arguments[0].components.map(&:class)).to eq([
          Keisan::Parsing::Variable
        ])
        expect(parser.components[0].arguments[1].components[1].arguments[1].components.map(&:class)).to eq([
          Keisan::Parsing::Number,
          Keisan::Parsing::LineSeparator,
          Keisan::Parsing::Variable
        ])
      end
    end

    context "keyword" do
      it "parses the keyword into a function call" do
        parser = described_class.new(string: "let x = 5")
        expect(parser.components.map(&:class)).to eq([Keisan::Parsing::Function])
        expect(parser.components.first.arguments.count).to eq 1
        expect(parser.components.first.arguments.first.components.map(&:class)).to eq([
          Keisan::Parsing::Variable,
          Keisan::Parsing::Assignment,
          Keisan::Parsing::Number
        ])
      end
    end

    context "hash definition" do
      it "parses the hash correctly" do
        parser = described_class.new(string: "{'foo': 1, 'bar': x**2 + 1}")

        expect(parser.components.map(&:class)).to eq([Keisan::Parsing::Hash])

        expect(parser.components.first.key_value_pairs[0][0].value).to eq "foo"
        expect(parser.components.first.key_value_pairs[0][1]).to be_a(Keisan::Parsing::RoundGroup)
        expect(parser.components.first.key_value_pairs[1][0].value).to eq "bar"
        expect(parser.components.first.key_value_pairs[1][1]).to be_a(Keisan::Parsing::RoundGroup)

        expect(parser.components.first.key_value_pairs[1][1].components.map(&:class)).to eq([
          Keisan::Parsing::Variable,
          Keisan::Parsing::Exponent,
          Keisan::Parsing::Number,
          Keisan::Parsing::Plus,
          Keisan::Parsing::Number
        ])
      end
    end
  end
end

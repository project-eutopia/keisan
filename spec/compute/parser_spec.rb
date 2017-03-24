require "spec_helper"

RSpec.describe Compute::Parser do
  describe "components" do
    context "simple operations" do
      it "has correct components" do
        parser = described_class.new(string: "1 + 2 - 3 * 4 / x")

        expect(parser.components.map(&:class)).to match_array([
          Compute::Parsing::Number,
          Compute::Parsing::Plus,
          Compute::Parsing::Number,
          Compute::Parsing::Minus,
          Compute::Parsing::Number,
          Compute::Parsing::Times,
          Compute::Parsing::Number,
          Compute::Parsing::Divide,
          Compute::Parsing::Variable
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
        parser = described_class.new(string: "+2 * -x")

        expect(parser.components.map(&:class)).to match_array([
          Compute::Parsing::UnaryPlus,
          Compute::Parsing::Number,
          Compute::Parsing::Times,
          Compute::Parsing::UnaryMinus,
          Compute::Parsing::Variable
        ])

        expect(parser.components[1].value).to eq 2
        expect(parser.components[4].name).to eq "x"
      end
    end

    context "has brackets" do
      it "uses Parsing::Group to contain the element" do
        parser = described_class.new(string: "2 * (3 + 5)")

        expect(parser.components.map(&:class)).to match_array([
          Compute::Parsing::Number,
          Compute::Parsing::Times,
          Compute::Parsing::RoundGroup
        ])

        expect(parser.components[0].value).to eq 2

        group = parser.components[2]
        expect(group.components.map(&:class)).to match_array([
          Compute::Parsing::Number,
          Compute::Parsing::Plus,
          Compute::Parsing::Number
        ])

        expect(group.components[0].value).to eq 3
        expect(group.components[2].value).to eq 5
      end

      context "square bracket indexing" do
        it "handles simple array" do
          parser = described_class.new(string: "[1,2]")
          expect(parser.components.map(&:class)).to match_array([
            Compute::Parsing::List
          ])

          arguments = parser.components[0].arguments
          expect(arguments.count).to eq 2
          expect(arguments[0].components.map(&:class)).to match_array([Compute::Parsing::Number])
          expect(arguments[0].components[0].value).to eq 1
          expect(arguments[1].components.map(&:class)).to match_array([Compute::Parsing::Number])
          expect(arguments[1].components[0].value).to eq 2
        end

        it "handles indexing an array" do
          parser = described_class.new(string: "[1,2,x][1+y]")
          expect(parser.components.map(&:class)).to match_array([
            Compute::Parsing::List,
            Compute::Parsing::Indexing
          ])

          arguments = parser.components[0].arguments
          expect(arguments.count).to eq 3
          expect(arguments[0].components.map(&:class)).to match_array([Compute::Parsing::Number])
          expect(arguments[0].components[0].value).to eq 1
          expect(arguments[1].components.map(&:class)).to match_array([Compute::Parsing::Number])
          expect(arguments[1].components[0].value).to eq 2
          expect(arguments[2].components.map(&:class)).to match_array([Compute::Parsing::Variable])
          expect(arguments[2].components[0].name).to eq "x"

          arguments = parser.components[1].arguments
          expect(arguments.count).to eq 1
          expect(arguments[0].components.map(&:class)).to match_array([
            Compute::Parsing::Number,
            Compute::Parsing::Plus,
            Compute::Parsing::Variable
          ])
          expect(arguments[0].components[0].value).to eq 1
          expect(arguments[0].components[2].name).to eq "y"
        end

        it "handles indexing a variable" do
          parser = described_class.new(string: "~a[1,2]")
          expect(parser.components.map(&:class)).to match_array([
            Compute::Parsing::BitwiseNot,
            Compute::Parsing::Variable,
            Compute::Parsing::Indexing
          ])

          expect(parser.components[1].name).to eq "a"
          arguments = parser.components[2].arguments
          expect(arguments[0].components.map(&:class)).to match_array([Compute::Parsing::Number])
          expect(arguments[0].components[0].value).to eq 1
          expect(arguments[1].components.map(&:class)).to match_array([Compute::Parsing::Number])
          expect(arguments[1].components[0].value).to eq 2
        end

        it "handles indexing a function call" do
          parser = described_class.new(string: "a(x)[1,2]")
          expect(parser.components.map(&:class)).to match_array([
            Compute::Parsing::Function,
            Compute::Parsing::Indexing
          ])

          expect(parser.components[0].name).to eq "a"
          expect(parser.components[0].arguments.count).to eq 1
          expect(parser.components[0].arguments[0].components.map(&:class)).to match_array([Compute::Parsing::Variable])
          expect(parser.components[0].arguments[0].components[0].name).to eq "x"

          arguments = parser.components[1].arguments
          expect(arguments[0].components.map(&:class)).to match_array([Compute::Parsing::Number])
          expect(arguments[0].components[0].value).to eq 1
          expect(arguments[1].components.map(&:class)).to match_array([Compute::Parsing::Number])
          expect(arguments[1].components[0].value).to eq 2
        end

        it "handles complicated case" do
          parser = described_class.new(string: "~func(x,y)[2][n-1,m+1]")

          expect(parser.components.map(&:class)).to match_array([
            Compute::Parsing::BitwiseNot,
            Compute::Parsing::Function,
            Compute::Parsing::Indexing,
            Compute::Parsing::Indexing
          ])
        end
      end
    end

    context "has nested brackets" do
      it "uses Parsing::Group to contain the element" do
        parser = described_class.new(string: "x ** (y * (1 + z))")

        expect(parser.components.map(&:class)).to match_array([
          Compute::Parsing::Variable,
          Compute::Parsing::Exponent,
          Compute::Parsing::RoundGroup
        ])

        expect(parser.components[0].name).to eq "x"

        group = parser.components[2]
        expect(group.components.map(&:class)).to match_array([
          Compute::Parsing::Variable,
          Compute::Parsing::Times,
          Compute::Parsing::RoundGroup
        ])

        expect(group.components[0].name).to eq "y"

        group = group.components[2]
        expect(group.components.map(&:class)).to match_array([
          Compute::Parsing::Number,
          Compute::Parsing::Plus,
          Compute::Parsing::Variable
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
            Compute::Parsing::Function
          ])

          fn = parser.components.first
          expect(fn.arguments).to match_array([])
        end
      end

      describe "one argument" do
        it "has one argument" do
          parser = described_class.new(string: "f(x+1)")
          expect(parser.components.map(&:class)).to match_array([
            Compute::Parsing::Function
          ])

          fn = parser.components.first
          expect(fn.arguments.count).to eq 1

          expect(fn.arguments.first.components.map(&:class)).to match_array([
            Compute::Parsing::Variable,
            Compute::Parsing::Plus,
            Compute::Parsing::Number
          ])
          expect(fn.arguments.first.components[0].name).to eq "x"
          expect(fn.arguments.first.components[2].value).to eq 1
        end
      end

      describe "two arguments" do
        it "has two arguments" do
          parser = described_class.new(string: "f(x+1, y-1)")
          expect(parser.components.map(&:class)).to match_array([
            Compute::Parsing::Function
          ])

          fn = parser.components.first
          expect(fn.arguments.count).to eq 2

          expect(fn.arguments.first.components.map(&:class)).to match_array([
            Compute::Parsing::Variable,
            Compute::Parsing::Plus,
            Compute::Parsing::Number
          ])
          expect(fn.arguments.first.components[0].name).to eq "x"
          expect(fn.arguments.first.components[2].value).to eq 1

          expect(fn.arguments.last.components.map(&:class)).to match_array([
            Compute::Parsing::Variable,
            Compute::Parsing::Minus,
            Compute::Parsing::Number
          ])
          expect(fn.arguments.last.components[0].name).to eq "y"
          expect(fn.arguments.last.components[2].value).to eq 1
        end
      end

      it "contains the correct arguments" do
        parser = described_class.new(string: "1 + atan2(x + 1, y - 1)")

        expect(parser.components.map(&:class)).to match_array([
          Compute::Parsing::Number,
          Compute::Parsing::Plus,
          Compute::Parsing::Function
        ])

        expect(parser.components[0].value).to eq 1
        expect(parser.components[2].name).to eq "atan2"

        arguments = parser.components[2].arguments
        expect(arguments.count).to eq 2

        expect(arguments.all? {|argument| argument.is_a?(Compute::Parsing::Argument)}).to be true

        expect(arguments.first.components.map(&:class)).to match_array([
          Compute::Parsing::Variable,
          Compute::Parsing::Plus,
          Compute::Parsing::Number
        ])
        expect(arguments.first.components[0].name).to eq "x"
        expect(arguments.first.components[2].value).to eq 1

        expect(arguments.last.components.map(&:class)).to match_array([
          Compute::Parsing::Variable,
          Compute::Parsing::Minus,
          Compute::Parsing::Number
        ])
        expect(arguments.last.components[0].name).to eq "y"
        expect(arguments.last.components[2].value).to eq 1
      end
    end

    context "bitwise operators" do
      it "parses correctly" do
        parser = described_class.new(string: "~~~~9 & 8 | (~16 + 1) ^ 4")

        expect(parser.components.map(&:class)).to match_array([
          Compute::Parsing::BitwiseNotNot,
          Compute::Parsing::Number,
          Compute::Parsing::BitwiseAnd,
          Compute::Parsing::Number,
          Compute::Parsing::BitwiseOr,
          Compute::Parsing::RoundGroup,
          Compute::Parsing::BitwiseXor,
          Compute::Parsing::Number
        ])

        expect(parser.components[1].value).to eq 9
        expect(parser.components[3].value).to eq 8
        expect(parser.components[7].value).to eq 4

        group = parser.components[5]
        expect(group.components.map(&:class)).to match_array([
          Compute::Parsing::BitwiseNot,
          Compute::Parsing::Number,
          Compute::Parsing::Plus,
          Compute::Parsing::Number
        ])

        expect(group.components[1].value).to eq 16
        expect(group.components[3].value).to eq 1
      end
    end

    context "logical operators" do
      it "parses correctly" do
        parser = described_class.new(string: "true && !!!false || (!false || 2 > 0) && 5 >= 5")

        expect(parser.components.map(&:class)).to match_array([
          Compute::Parsing::Boolean,
          Compute::Parsing::LogicalAnd,
          Compute::Parsing::LogicalNot,
          Compute::Parsing::Boolean,
          Compute::Parsing::LogicalOr,
          Compute::Parsing::RoundGroup,
          Compute::Parsing::LogicalAnd,
          Compute::Parsing::Number,
          Compute::Parsing::LogicalGreaterThanOrEqualTo,
          Compute::Parsing::Number
        ])

        expect(parser.components[0].value).to eq true
        expect(parser.components[3].value).to eq false
        expect(parser.components[7].value).to eq 5
        expect(parser.components[9].value).to eq 5

        group = parser.components[5]
        expect(group.components.map(&:class)).to match_array([
          Compute::Parsing::LogicalNot,
          Compute::Parsing::Boolean,
          Compute::Parsing::LogicalOr,
          Compute::Parsing::Number,
          Compute::Parsing::LogicalGreaterThan,
          Compute::Parsing::Number
        ])

        expect(group.components[1].value).to eq false
        expect(group.components[3].value).to eq 2
        expect(group.components[5].value).to eq 0
      end
    end

    context "combination" do
      it "parses correctly" do
        parser = described_class.new(string: "-sin(x ** (2+1)) + (a + b*z) / (c + d*z)")

        expect(parser.components.map(&:class)).to match_array([
          Compute::Parsing::UnaryMinus,
          Compute::Parsing::Function,
          Compute::Parsing::Plus,
          Compute::Parsing::RoundGroup,
          Compute::Parsing::Divide,
          Compute::Parsing::RoundGroup
        ])

        function = parser.components[1]
        expect(function.name).to eq "sin"
        expect(function.arguments.count).to eq 1
        argument = function.arguments.first

        expect(argument.components.map(&:class)).to match_array([
          Compute::Parsing::Variable,
          Compute::Parsing::Exponent,
          Compute::Parsing::RoundGroup
        ])

        expect(argument.components[0].name).to eq "x"
        group = argument.components[2]

        expect(group.components.map(&:class)).to match_array([
          Compute::Parsing::Number,
          Compute::Parsing::Plus,
          Compute::Parsing::Number
        ])

        expect(group.components[0].value).to eq 2
        expect(group.components[2].value).to eq 1

        numerator = parser.components[3]
        denominator = parser.components[5]

        expect(numerator.components.map(&:class)).to match_array([
          Compute::Parsing::Variable,
          Compute::Parsing::Plus,
          Compute::Parsing::Variable,
          Compute::Parsing::Times,
          Compute::Parsing::Variable
        ])
        expect(denominator.components.map(&:class)).to match_array([
          Compute::Parsing::Variable,
          Compute::Parsing::Plus,
          Compute::Parsing::Variable,
          Compute::Parsing::Times,
          Compute::Parsing::Variable
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
          Compute::Parsing::String,
          Compute::Parsing::Plus,
          Compute::Parsing::String
        ])

        expect(parser.components[0].value).to eq "this is a "
        expect(parser.components[2].value).to eq "test"
      end
    end
  end
end

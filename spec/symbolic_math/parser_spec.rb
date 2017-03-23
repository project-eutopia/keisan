require "spec_helper"

RSpec.describe SymbolicMath::Parser do
  describe "components" do
    context "simple operations" do
      it "has correct components" do
        parser = described_class.new(string: "1 + 2 - 3 * 4 / x")

        expect(parser.components.map(&:class)).to match_array([
          SymbolicMath::Parsing::Number,
          SymbolicMath::Parsing::Plus,
          SymbolicMath::Parsing::Number,
          SymbolicMath::Parsing::Minus,
          SymbolicMath::Parsing::Number,
          SymbolicMath::Parsing::Times,
          SymbolicMath::Parsing::Number,
          SymbolicMath::Parsing::Divide,
          SymbolicMath::Parsing::Variable
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
          SymbolicMath::Parsing::UnaryPlus,
          SymbolicMath::Parsing::Number,
          SymbolicMath::Parsing::Times,
          SymbolicMath::Parsing::UnaryMinus,
          SymbolicMath::Parsing::Variable
        ])

        expect(parser.components[1].value).to eq 2
        expect(parser.components[4].name).to eq "x"
      end
    end

    context "has brackets" do
      it "uses Parsing::Group to contain the element" do
        parser = described_class.new(string: "2 * (3 + 5)")

        expect(parser.components.map(&:class)).to match_array([
          SymbolicMath::Parsing::Number,
          SymbolicMath::Parsing::Times,
          SymbolicMath::Parsing::Group
        ])

        expect(parser.components[0].value).to eq 2

        group = parser.components[2]
        expect(group.components.map(&:class)).to match_array([
          SymbolicMath::Parsing::Number,
          SymbolicMath::Parsing::Plus,
          SymbolicMath::Parsing::Number
        ])

        expect(group.components[0].value).to eq 3
        expect(group.components[2].value).to eq 5
      end
    end

    context "has nested brackets" do
      it "uses Parsing::Group to contain the element" do
        parser = described_class.new(string: "x ** (y * (1 + z))")

        expect(parser.components.map(&:class)).to match_array([
          SymbolicMath::Parsing::Variable,
          SymbolicMath::Parsing::Exponent,
          SymbolicMath::Parsing::Group
        ])

        expect(parser.components[0].name).to eq "x"

        group = parser.components[2]
        expect(group.components.map(&:class)).to match_array([
          SymbolicMath::Parsing::Variable,
          SymbolicMath::Parsing::Times,
          SymbolicMath::Parsing::Group
        ])

        expect(group.components[0].name).to eq "y"

        group = group.components[2]
        expect(group.components.map(&:class)).to match_array([
          SymbolicMath::Parsing::Number,
          SymbolicMath::Parsing::Plus,
          SymbolicMath::Parsing::Variable
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
            SymbolicMath::Parsing::Function
          ])

          fn = parser.components.first
          expect(fn.arguments).to match_array([])
        end
      end

      describe "one argument" do
        it "has one argument" do
          parser = described_class.new(string: "f(x+1)")
          expect(parser.components.map(&:class)).to match_array([
            SymbolicMath::Parsing::Function
          ])

          fn = parser.components.first
          expect(fn.arguments.count).to eq 1

          expect(fn.arguments.first.components.map(&:class)).to match_array([
            SymbolicMath::Parsing::Variable,
            SymbolicMath::Parsing::Plus,
            SymbolicMath::Parsing::Number
          ])
          expect(fn.arguments.first.components[0].name).to eq "x"
          expect(fn.arguments.first.components[2].value).to eq 1
        end
      end

      describe "two arguments" do
        it "has two arguments" do
          parser = described_class.new(string: "f(x+1, y-1)")
          expect(parser.components.map(&:class)).to match_array([
            SymbolicMath::Parsing::Function
          ])

          fn = parser.components.first
          expect(fn.arguments.count).to eq 2

          expect(fn.arguments.first.components.map(&:class)).to match_array([
            SymbolicMath::Parsing::Variable,
            SymbolicMath::Parsing::Plus,
            SymbolicMath::Parsing::Number
          ])
          expect(fn.arguments.first.components[0].name).to eq "x"
          expect(fn.arguments.first.components[2].value).to eq 1

          expect(fn.arguments.last.components.map(&:class)).to match_array([
            SymbolicMath::Parsing::Variable,
            SymbolicMath::Parsing::Minus,
            SymbolicMath::Parsing::Number
          ])
          expect(fn.arguments.last.components[0].name).to eq "y"
          expect(fn.arguments.last.components[2].value).to eq 1
        end
      end

      it "contains the correct arguments" do
        parser = described_class.new(string: "1 + atan2(x + 1, y - 1)")

        expect(parser.components.map(&:class)).to match_array([
          SymbolicMath::Parsing::Number,
          SymbolicMath::Parsing::Plus,
          SymbolicMath::Parsing::Function
        ])

        expect(parser.components[0].value).to eq 1
        expect(parser.components[2].name).to eq "atan2"

        arguments = parser.components[2].arguments
        expect(arguments.count).to eq 2

        expect(arguments.all? {|argument| argument.is_a?(SymbolicMath::Parsing::Argument)}).to be true

        expect(arguments.first.components.map(&:class)).to match_array([
          SymbolicMath::Parsing::Variable,
          SymbolicMath::Parsing::Plus,
          SymbolicMath::Parsing::Number
        ])
        expect(arguments.first.components[0].name).to eq "x"
        expect(arguments.first.components[2].value).to eq 1

        expect(arguments.last.components.map(&:class)).to match_array([
          SymbolicMath::Parsing::Variable,
          SymbolicMath::Parsing::Minus,
          SymbolicMath::Parsing::Number
        ])
        expect(arguments.last.components[0].name).to eq "y"
        expect(arguments.last.components[2].value).to eq 1
      end
    end

    context "bitwise operators" do
      it "parses correctly" do
        parser = described_class.new(string: "~~~~9 & 8 | (~16 + 1) ^ 4")

        expect(parser.components.map(&:class)).to match_array([
          SymbolicMath::Parsing::BitwiseNotNot,
          SymbolicMath::Parsing::Number,
          SymbolicMath::Parsing::BitwiseAnd,
          SymbolicMath::Parsing::Number,
          SymbolicMath::Parsing::BitwiseOr,
          SymbolicMath::Parsing::Group,
          SymbolicMath::Parsing::BitwiseXor,
          SymbolicMath::Parsing::Number
        ])

        expect(parser.components[1].value).to eq 9
        expect(parser.components[3].value).to eq 8
        expect(parser.components[7].value).to eq 4

        group = parser.components[5]
        expect(group.components.map(&:class)).to match_array([
          SymbolicMath::Parsing::BitwiseNot,
          SymbolicMath::Parsing::Number,
          SymbolicMath::Parsing::Plus,
          SymbolicMath::Parsing::Number
        ])

        expect(group.components[1].value).to eq 16
        expect(group.components[3].value).to eq 1
      end
    end

    context "logical operators" do
      it "parses correctly" do
        parser = described_class.new(string: "true && !!!false || (!false || 2 > 0) && 5 >= 5")

        expect(parser.components.map(&:class)).to match_array([
          SymbolicMath::Parsing::Boolean,
          SymbolicMath::Parsing::LogicalAnd,
          SymbolicMath::Parsing::LogicalNot,
          SymbolicMath::Parsing::Boolean,
          SymbolicMath::Parsing::LogicalOr,
          SymbolicMath::Parsing::Group,
          SymbolicMath::Parsing::LogicalAnd,
          SymbolicMath::Parsing::Number,
          SymbolicMath::Parsing::LogicalGreaterThanOrEqualTo,
          SymbolicMath::Parsing::Number
        ])

        expect(parser.components[0].value).to eq true
        expect(parser.components[3].value).to eq false
        expect(parser.components[7].value).to eq 5
        expect(parser.components[9].value).to eq 5

        group = parser.components[5]
        expect(group.components.map(&:class)).to match_array([
          SymbolicMath::Parsing::LogicalNot,
          SymbolicMath::Parsing::Boolean,
          SymbolicMath::Parsing::LogicalOr,
          SymbolicMath::Parsing::Number,
          SymbolicMath::Parsing::LogicalGreaterThan,
          SymbolicMath::Parsing::Number
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
          SymbolicMath::Parsing::UnaryMinus,
          SymbolicMath::Parsing::Function,
          SymbolicMath::Parsing::Plus,
          SymbolicMath::Parsing::Group,
          SymbolicMath::Parsing::Divide,
          SymbolicMath::Parsing::Group
        ])

        function = parser.components[1]
        expect(function.name).to eq "sin"
        expect(function.arguments.count).to eq 1
        argument = function.arguments.first

        expect(argument.components.map(&:class)).to match_array([
          SymbolicMath::Parsing::Variable,
          SymbolicMath::Parsing::Exponent,
          SymbolicMath::Parsing::Group
        ])

        expect(argument.components[0].name).to eq "x"
        group = argument.components[2]

        expect(group.components.map(&:class)).to match_array([
          SymbolicMath::Parsing::Number,
          SymbolicMath::Parsing::Plus,
          SymbolicMath::Parsing::Number
        ])

        expect(group.components[0].value).to eq 2
        expect(group.components[2].value).to eq 1

        numerator = parser.components[3]
        denominator = parser.components[5]

        expect(numerator.components.map(&:class)).to match_array([
          SymbolicMath::Parsing::Variable,
          SymbolicMath::Parsing::Plus,
          SymbolicMath::Parsing::Variable,
          SymbolicMath::Parsing::Times,
          SymbolicMath::Parsing::Variable
        ])
        expect(denominator.components.map(&:class)).to match_array([
          SymbolicMath::Parsing::Variable,
          SymbolicMath::Parsing::Plus,
          SymbolicMath::Parsing::Variable,
          SymbolicMath::Parsing::Times,
          SymbolicMath::Parsing::Variable
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
          SymbolicMath::Parsing::String,
          SymbolicMath::Parsing::Plus,
          SymbolicMath::Parsing::String
        ])

        expect(parser.components[0].value).to eq "this is a "
        expect(parser.components[2].value).to eq "test"
      end
    end
  end
end

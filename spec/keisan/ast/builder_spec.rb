require "spec_helper"

RSpec.describe Keisan::AST::Builder do
  let(:my_context) {
    my_context = Keisan::Context.new
    my_context.register_variable!("x", 5)
    my_context
  }

  context "simple operations" do
    operations = {
      "-5"                   => -5,
      "1 + 2"                => 3,
      "7.5 - 3"              => 4.5,
      "7.5 +- 3"             => 4.5,
      "7.5 -+- 3"            => 10.5,
      "2 + 3 * x"            => 17,
      "8 / 5"                => Rational(8,5),
      "(1+2) * (3+4*(1+1))"  => 33,
      "4**2 + 3 * 5"         => 31,
      "2 ** (1/2)"           => Math.sqrt(2),
      "~~2"                  => 2,
      "~~~2"                 => -3,
      "24 & 16 | 5 & ~4"     => 17,
      "7 ^ 1"                => 6,
      "((2))"                => 2,
      "!false"               => true,
      "!!!!false"            => false,
      "0 < 2"                => true,
      "2 < 2"                => false,
      "4 < 2"                => false,
      "0 <= 2"               => true,
      "2 <= 2"               => true,
      "4 <= 2"               => false,
      "0 > 2"                => false,
      "2 > 2"                => false,
      "4 > 2"                => true,
      "0 >= 2"               => false,
      "2 >= 2"               => true,
      "4 >= 2"               => true,
      "true  || true"        => true,
      "false || true"        => true,
      "true  || false"       => true,
      "false || false"       => false,
      "true  && true"        => true,
      "false && true"        => false,
      "true  && false"       => false,
      "false && false"       => false,
      "0 == 1"               => false,
      "1 == 1"               => true,
      "0 != 1"               => true,
      "1 != 1"               => false,
      "1 + 2 == 9 / 3"       => true,
      "'hello ' + \"world\"" => "hello world",
      "[1,2,3]"              => [1,2,3],
      "[2,4,6,8][1]"         => 4,
      "[[1,3],[5,7]][1][0]"  => 5
    }

    operations.each do |operation, value|
      it "correctly builds the AST for #{operation}" do
        expect(described_class.new(string: operation).ast.value(my_context)).to eq value
      end
    end
  end

  context "function" do
    it "properly parses" do
      expect(described_class.new(string: "sin(PI)").ast.value).to be_within(1e-10).of(0)
      my_context.register_function!("my_func", Proc.new { 11 })
      expect(described_class.new(string: "5 + my_func()").ast.value(my_context)).to eq 16
    end
  end

  context "list" do
    it "properly parses" do
      my_context.register_function!("f", Proc.new { [3,5,7] })
      expect(described_class.new(string: "f()").ast.value(my_context)).to eq [3,5,7]
      expect(described_class.new(string: "f()[1]").ast.value(my_context)).to eq 5
    end
  end

  context "with variables" do
    it "value raises error unless defined" do
      ast = described_class.new(string: "x + 1").ast
      expect { ast.value }.to raise_error(Keisan::Exceptions::UndefinedVariableError)
    end

    it "fills in variable" do
      ast = described_class.new(string: "x + 1").ast
      my_context = Keisan::Context.new
      my_context.register_variable!(:x, 3)
      expect(ast.value(my_context)).to eq 4
    end
  end

  context "dot operators" do
    it "parses it correctly" do
      ast = described_class.new(string: "[1,3,5,7].size").ast
      expect(ast.value).to eq 4
    end
  end

  context "multi line" do
    it "parses correctly" do
      ast = described_class.new(string: "f(x;,;y;;) = 5+x; f(1+2,50)**2").ast
      expect(ast.value).to eq 64
    end
  end
end

require "spec_helper"

RSpec.describe Keisan::AST::Time do
  describe "evaluate" do
    it "reduces to a time when adding numbers" do
      ast = Keisan::AST.parse("time(2018, 11, 20) + 1")
      expect(ast.evaluate).to be_a(described_class)
      expect(ast.evaluate.value).to eq Time.new(2018, 11, 20, 0, 0, 1)

      ast = Keisan::AST.parse("2 + time(2018, 11)")
      expect(ast.evaluate).to be_a(described_class)
      expect(ast.evaluate.value).to eq Time.new(2018, 11, 1, 0, 0, 2)

      ast = Keisan::AST.parse("3 + time('1999-12-31 23:59:59')")
      expect(ast.evaluate).to be_a(described_class)
      expect(ast.evaluate.value).to eq Time.new(2000, 1, 1, 0, 0, 2)

      ast = Keisan::AST.parse("time(2017) > time(2018)")
      expect(ast.evaluate).to be_a(Keisan::AST::Boolean)
      expect(ast.evaluate.value).to eq false

      ast = Keisan::AST.parse("time(2017, 10, 10) >= time(2017, 10, 10)")
      expect(ast.evaluate).to be_a(Keisan::AST::Boolean)
      expect(ast.evaluate.value).to eq true

      ast = Keisan::AST.parse("time(2017,12,31,12,0,0) < time(2018,12,31,12,0,1)")
      expect(ast.evaluate).to be_a(Keisan::AST::Boolean)
      expect(ast.evaluate.value).to eq true

      ast = Keisan::AST.parse("time(2017, 10, 10, 12, 34, 56) <= time(2017, 10, 10, 12, 34, 55)")
      expect(ast.evaluate).to be_a(Keisan::AST::Boolean)
      expect(ast.evaluate.value).to eq false

      ast = Keisan::AST.parse("time(1999, 12, 31, 12, 0, 0) == time('1999-12-31 12:00:00')")
      expect(ast.evaluate).to be_a(Keisan::AST::Boolean)
      expect(ast.evaluate.value).to eq true

      ast = Keisan::AST.parse("time(1999, 12, 31) != time('1999-12-31')")
      expect(ast.evaluate).to be_a(Keisan::AST::Boolean)
      expect(ast.evaluate.value).to eq false

      ast = Keisan::AST.parse("time(2000) + time(2000)")
      expect(ast.evaluate).to be_a(Keisan::AST::Plus)
      expect{ast.evaluate.value}.to raise_error(TypeError)
    end

    it "works in arrays" do
      calculator = Keisan::Calculator.new
      calculator.evaluate("a = [10, time(2018, 11, 10, 9, 8, 7), today()]")
      calculator.evaluate("a[1] += 5")
      expect(calculator.evaluate("a[0] + a[1]").value).to eq Time.new(2018, 11, 10, 9, 8, 22)
    end
  end

  describe "time methods" do
    describe "now" do
      it "returns todays time" do
        allow(Time).to receive(:now).and_return(Time.new(2010, 6, 6, 12, 34, 56))

        ast = Keisan::AST.parse("now()")
        expect(ast.evaluate).to be_a(described_class)
        expect(ast.evaluate.value).to eq Time.new(2010, 6, 6, 12, 34, 56)
      end
    end

    describe "year" do
      it "returns year of time" do
        ast = Keisan::AST.parse("time(2018, 4, 8, 12, 30, 10).year()")
        expect(ast.evaluate).to be_a(Keisan::AST::Number)
        expect(ast.evaluate.value).to eq 2018
      end
    end

    describe "month" do
      it "returns month of time" do
        ast = Keisan::AST.parse("time(2018, 4, 8, 12, 30, 10).month()")
        expect(ast.evaluate).to be_a(Keisan::AST::Number)
        expect(ast.evaluate.value).to eq 4
      end
    end

    describe "day" do
      it "returns day of time" do
        ast = Keisan::AST.parse("time(2018, 4, 8, 12, 30, 10).day()")
        expect(ast.evaluate).to be_a(Keisan::AST::Number)
        expect(ast.evaluate.value).to eq 8
      end
    end

    describe "weekday" do
      it "returns weekday of time" do
        ast = Keisan::AST.parse("time(2018, 4, 8, 12, 30, 10).weekday()")
        expect(ast.evaluate).to be_a(Keisan::AST::Number)
        expect(ast.evaluate.value).to eq 0
      end
    end

    describe "hour" do
      it "returns hour of time" do
        ast = Keisan::AST.parse("time(2018, 4, 8, 12, 30, 10).hour()")
        expect(ast.evaluate).to be_a(Keisan::AST::Number)
        expect(ast.evaluate.value).to eq 12
      end
    end

    describe "minute" do
      it "returns minute of time" do
        ast = Keisan::AST.parse("time(2018, 4, 8, 12, 30, 10).minute()")
        expect(ast.evaluate).to be_a(Keisan::AST::Number)
        expect(ast.evaluate.value).to eq 30
      end
    end

    describe "second" do
      it "returns second of time" do
        ast = Keisan::AST.parse("time(2018, 4, 8, 12, 30, 10).second()")
        expect(ast.evaluate).to be_a(Keisan::AST::Number)
        expect(ast.evaluate.value).to eq 10
      end
    end
  end

  describe "#to_s" do
    it "outputs correct date format" do
      calculator = Keisan::Calculator.new
      time = calculator.ast("time(2018, 11, 20, 12, 34, 56)").evaluate
      expect(time.to_s).to eq "2018-11-20 12:34:56"
    end
  end
end

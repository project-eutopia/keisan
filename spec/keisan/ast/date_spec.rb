require "spec_helper"

RSpec.describe Keisan::AST::Date do
  describe "is_constant?" do
    it "is true" do
      date = Keisan::AST.parse("date(2018, 11, 20)").evaluate
      expect(date.is_constant?).to eq true
    end
  end

  describe "evaluate" do
    it "reduces to a date when adding numbers" do
      ast = Keisan::AST.parse("date(2018, 11, 20) + 1")
      expect(ast.evaluate).to be_a(described_class)
      expect(ast.evaluate.value).to eq Date.new(2018, 11, 21)

      ast = Keisan::AST.parse("2 + date(2018, 11)")
      expect(ast.evaluate).to be_a(described_class)
      expect(ast.evaluate.value).to eq Date.new(2018, 11, 3)

      ast = Keisan::AST.parse("3 + date('3rd Feb 2001')")
      expect(ast.evaluate).to be_a(described_class)
      expect(ast.evaluate.value).to eq Date.new(2001, 2, 6)

      ast = Keisan::AST.parse("date(2017) > date(2018)")
      expect(ast.evaluate).to be_a(Keisan::AST::Boolean)
      expect(ast.evaluate.value).to eq false

      ast = Keisan::AST.parse("date(2017, 10, 10) >= date(2017, 10, 10)")
      expect(ast.evaluate).to be_a(Keisan::AST::Boolean)
      expect(ast.evaluate.value).to eq true

      ast = Keisan::AST.parse("date(2017) < date(2018)")
      expect(ast.evaluate).to be_a(Keisan::AST::Boolean)
      expect(ast.evaluate.value).to eq true

      ast = Keisan::AST.parse("date(2017, 10, 10) <= date(2017, 10, 10)")
      expect(ast.evaluate).to be_a(Keisan::AST::Boolean)
      expect(ast.evaluate.value).to eq true

      ast = Keisan::AST.parse("date(1999, 12, 31) == date('1999-12-31')")
      expect(ast.evaluate).to be_a(Keisan::AST::Boolean)
      expect(ast.evaluate.value).to eq true

      ast = Keisan::AST.parse("date(1999, 12, 31) != date('1999-12-31')")
      expect(ast.evaluate).to be_a(Keisan::AST::Boolean)
      expect(ast.evaluate.value).to eq false

      ast = Keisan::AST.parse("date(2000) + date(2000)")
      expect(ast.evaluate).to be_a(Keisan::AST::Plus)
      expect{ast.evaluate.value}.to raise_error(TypeError)
    end

    it "works in arrays" do
      calculator = Keisan::Calculator.new
      calculator.evaluate("a = [10, date(2018, 11, 10), today()]")
      calculator.evaluate("a[1] += 1")
      expect(calculator.evaluate("a[0] + a[1]").value).to eq Date.new(2018, 11, 21)
    end
  end

  describe "date methods" do
    describe "today" do
      it "returns todays date" do
        allow(Date).to receive(:today).and_return(Date.new(2000, 4, 15))

        ast = Keisan::AST.parse("today()")
        expect(ast.evaluate).to be_a(described_class)
        expect(ast.evaluate.value).to eq Date.new(2000, 4, 15)
      end
    end

    describe "weekday" do
      it "returns the weekday number" do
        ast = Keisan::AST.parse("date(2018, 11, 20).weekday()")
        expect(ast.evaluate).to be_a(Keisan::AST::Number)
        expect(ast.evaluate.value).to eq 2
      end
    end

    describe "day" do
      it "returns the day number in month" do
        ast = Keisan::AST.parse("date(2018, 11, 20).day()")
        expect(ast.evaluate).to be_a(Keisan::AST::Number)
        expect(ast.evaluate.value).to eq 20
      end
    end

    describe "month" do
      it "returns the month number" do
        ast = Keisan::AST.parse("date(2018, 11, 20).month()")
        expect(ast.evaluate).to be_a(Keisan::AST::Number)
        expect(ast.evaluate.value).to eq 11
      end
    end

    describe "year" do
      it "returns the year number" do
        ast = Keisan::AST.parse("date(2018, 11, 20).year()")
        expect(ast.evaluate).to be_a(Keisan::AST::Number)
        expect(ast.evaluate.value).to eq 2018
      end
    end

    describe "#to_time" do
      it "converts date to time" do
        calculator = Keisan::Calculator.new
        time = calculator.ast("date(2018, 11, 20).to_time").evaluate
        expect(time).to be_a(Keisan::AST::Time)
        expect(time.to_s).to eq "2018-11-20 00:00:00"
      end
    end

    describe "#epoch_days" do
      it "returns the number of days since Unix epoch" do
        calculator = Keisan::Calculator.new
        time = calculator.ast("date(1970, 2, 2).epoch_days").evaluate
        expect(time).to be_a(Keisan::AST::Number)
        expect(time.value).to eq 32
      end
    end

    describe "#epoch_seconds" do
      it "returns the number of days since Unix epoch" do
        calculator = Keisan::Calculator.new
        time = calculator.ast("date(1970, 1, 2).epoch_seconds").evaluate
        expect(time).to be_a(Keisan::AST::Number)
        expect(time.value).to eq 86400
      end
    end
  end

  describe "#to_s" do
    it "outputs correct date format" do
      calculator = Keisan::Calculator.new
      date = calculator.ast("date(2018, 11, 20)").evaluate
      expect(date.to_s).to eq "2018-11-20"
    end
  end
end

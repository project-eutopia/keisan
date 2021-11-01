require "spec_helper"

RSpec.describe Keisan::AST::Cache do
  describe "caching" do
    context "not frozen" do
      it "adds to the cache when calling #fetch_or_build" do
        cache = described_class.new

        expect(cache.instance_variable_get(:@cache)).to eq({})
        expect(cache.has_key?("x+1")).to eq false
        expect(cache.fetch_or_build("x+1")).to be_a(Keisan::AST::Plus)
        expect(cache.instance_variable_get(:@cache).has_key?("x+1")).to eq true
        expect(cache.has_key?("x+1")).to eq true
        expect(cache.instance_variable_get(:@cache)["x+1"]).to be_a(Keisan::AST::Plus)
        expect(cache.instance_variable_get(:@cache)["x+1"].to_s).to eq "x+1"
      end
    end

    context "frozen" do
      it "does not add to the cache when calling #fetch_or_build" do
        cache = described_class.new
        cache.freeze

        expect(cache.instance_variable_get(:@cache)).to eq({})
        expect(cache.has_key?("x+1")).to eq false
        expect(cache.fetch_or_build("x+1")).to be_a(Keisan::AST::Plus)
        expect(cache.instance_variable_get(:@cache)).to eq({})
        expect(cache.has_key?("x+1")).to eq false
      end
    end
  end

  describe "x = 15; 10*x**2 + exp(-x/5.0)" do
    it "should be at least 5 times faster than no caching" do
      # This benchmark test can sometimes be flaky (e.g. caching is only 4.8
      # times faster). To mitigate this, we will try 3 times until the benchmark
      # passes.
      attempts = 0
      success = false

      while attempts < 3
        uncached_calculator = Keisan::Calculator.new

        uncached_before = Time.now
        100.times do
          uncached_calculator.evaluate("x = 15; 10*x**2 + exp(-x/5.0)")
        end
        uncached_after = Time.now

        cache = described_class.new
        cached_calculator = Keisan::Calculator.new(cache: cache)

        cached_before = Time.now
        100.times do
          cached_calculator.evaluate("x = 15; 10*x**2 + exp(-x/5.0)")
        end
        cached_after = Time.now

        uncached_time = uncached_after - uncached_before
        cached_time = cached_after - cached_before
        success = (5 * cached_time < uncached_time)
        break if success
      end

      expect(success).to be true
    end
  end
end

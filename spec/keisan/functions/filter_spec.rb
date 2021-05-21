require "spec_helper"

RSpec.describe Keisan::Functions::Filter do
  it "should be in the default context" do
    c = Keisan::Context.new
    expect(c.function("filter")).to be_a(described_class)
  end

  it "filters the list given the logical expression" do
    expect{Keisan::Calculator.new.evaluate("filter(10, x, x > 0)")}.to raise_error(Keisan::Exceptions::InvalidFunctionError)
    expect{Keisan::Calculator.new.evaluate("filter([-1,0,1], 4, x > 0)")}.to raise_error(Keisan::Exceptions::InvalidFunctionError)
    expect{Keisan::Calculator.new.evaluate("filter([-1,0,1], x, x)")}.to raise_error(Keisan::Exceptions::InvalidFunctionError)
    expect(Keisan::Calculator.new.evaluate("filter([-1,0,1], x, x > 0)")).to eq [1]
    expect(Keisan::Calculator.new.evaluate("select([1,2,3,4], x, x % 2 == 0)")).to eq [2,4]
    expect(Keisan::Calculator.new.simplify("[1,3,5].filter(x, x == 3)").to_s).to eq "[3]"
    expect(Keisan::Calculator.new.evaluate("l.filter(x, x['a'] == 2)", l: [{ 'a' => 2 }, { 'a' => 3 }]))
      .to eq([{ 'a' => 2 }])
    expect(Keisan::Calculator.new.evaluate("h['l'].filter(x, x['a'] == 2)", h: { 'l' => [{ 'a' => 2 }, { 'a' => 3 }] }))
      .to eq([{ 'a' => 2 }])
    expect(Keisan::Calculator.new.evaluate("l[0].filter(x, x['a'] == 2)", l: [[{ 'a' => 2 }, { 'a' => 3 }] ]))
      .to eq([{ 'a' => 2 }])
    expect(Keisan::Calculator.new.evaluate("l.filter(x, x[0])", l: [[true, 'a'], [false, 'b']]))
      .to eq([[true, 'a']])
  end

  it "filters the hash given the logical expression" do
    expect{Keisan::Calculator.new.evaluate("filter(10, k, v, v > 0)")}.to raise_error(Keisan::Exceptions::InvalidFunctionError)
    expect{Keisan::Calculator.new.evaluate("filter({'a': 1, 'b': 2}, k, 2, k > 0)")}.to raise_error(Keisan::Exceptions::InvalidFunctionError)
    expect{Keisan::Calculator.new.evaluate("filter({'a': 1, 'b': 2}, k, v, k)")}.to raise_error(Keisan::Exceptions::InvalidFunctionError)
    expect(Keisan::Calculator.new.evaluate("filter({'a': 1, 'bb': 2}, k, v, k.size == 2)")).to eq({"bb" => 2})
    expect(Keisan::Calculator.new.evaluate("h.filter(k, v, k == 'a')", h: { 'a' => 2, 'b' => 3 }))
      .to eq({ 'a' => 2 })
    expect(Keisan::Calculator.new.evaluate("h['hh'].filter(k, v, k == 'a')", h: { 'hh' => { 'a' => 2, 'b' => 3 } }))
      .to eq({ 'a' => 2 })
    expect(Keisan::Calculator.new.evaluate("l[0].filter(k, v, k == 'a')", l: [{ 'a' => 2, 'b' => 3 }]))
      .to eq({ 'a' => 2 })
    expect(Keisan::Calculator.new.evaluate("h.filter(k, v, v[0])", h: {'a' => [true, 'aa'], 'b' => [false, 'bb']}))
      .to eq({'a' => [true, 'aa']})
  end
end

require "spec_helper"

RSpec.describe Keisan::Context do
  it "contains function and variable registries" do
    my_context = described_class.new

    my_context.register_variable!("x", 2)
    my_context.register_function!("f", Proc.new {|x| x**2})
    expect(my_context.variable("x")).to eq 2
    expect(my_context.function("f").call(nil, 3)).to eq 9
  end

  it "has default variables and functions" do
    my_context = described_class.new

    expect(my_context.variable("PI")).to eq Math::PI
    expect(my_context.function("sin")).to be_a(Keisan::Function)
  end

  describe "spawn_child" do
    it "has parent context's variables and functions" do
      my_context = described_class.new

      my_context.register_variable!("x", 2)
      my_context.register_function!("f", Proc.new {|x| x**2})

      child_context = my_context.spawn_child
      expect(child_context.variable("x")).to eq 2
      expect(child_context.function("f").call(nil, 3)).to eq 9
    end

    it "can shadow parent" do
      my_context = described_class.new

      my_context.register_variable!("x", 2)
      my_context.register_variable!("y", 7)
      my_context.register_function!("f", Proc.new {|x| x**2})
      my_context.register_function!("g", Proc.new {|x| x-1})

      child_context = my_context.spawn_child
      child_context.register_variable!("x", 5)
      child_context.register_function!("f", Proc.new {|x| x**3})

      expect(my_context.variable("x")).to eq 2
      expect(my_context.variable("y")).to eq 7
      expect(my_context.function("f").call(nil, 2)).to eq 4
      expect(my_context.function("g").call(nil, 2)).to eq 1

      expect(child_context.variable("x")).to eq 5
      expect(child_context.variable("y")).to eq 7
      expect(child_context.function("f").call(nil, 2)).to eq 8
      expect(child_context.function("g").call(nil, 2)).to eq 1
    end
  end

  describe "random" do
    it "uses given Random object" do
      context1 = described_class.new(random: Random.new(1234))
      context2 = described_class.new(random: Random.new(1234))

      20.times do
        expect(context1.random.rand(100)).to eq context2.random.rand(100)
      end
    end

    it "uses parent random if does not have one" do
      rand1 = Random.new(2244)
      rand2 = Random.new(2244)

      parent = described_class.new(random: rand1)
      child  = described_class.new(parent: parent)

      20.times do
        expect(child.random.rand(100)).to eq rand2.rand(100)
      end
    end

    it "it shadows the parent random" do
      rand1 = Random.new(5151)
      rand1_copy = Random.new(5151)
      rand2 = Random.new(5959)

      parent = described_class.new(random: rand1)
      child  = described_class.new(parent: parent, random: rand2)

      matches = 20.times.map do |_|
        child.random.rand(100) == rand1_copy.rand(100)
      end

      expect(matches.any? {|bool| bool == false}).to be true
    end
  end

  describe "has_variable?" do
    let(:context) { described_class.new }

    it "returns true of variable is defined" do
      expect(context.has_variable?("PI")).to eq true
      expect(context.has_variable?("not_exist")).to eq false
      context.register_variable!("not_exist", 5)
      expect(context.has_variable?("not_exist")).to eq true
    end
  end

  describe "has_function?" do
    let(:context) { described_class.new }

    it "returns true of function is defined" do
      expect(context.has_function?("sin")).to eq true
      expect(context.has_function?("not_exist")).to eq false
      context.register_function!("not_exist", Proc.new { nil })
      expect(context.has_function?("not_exist")).to eq true
    end
  end

  describe "transient context" do
    it "has parent context's variables and functions" do
      my_context = described_class.new

      my_context.register_variable!("x", 2)
      my_context.register_function!("f", Proc.new {|x| x**2})

      child_context = my_context.spawn_child(transient: true)
      expect(child_context.variable("x")).to eq 2
      expect(child_context.function("f").call(nil, 3)).to eq 9
    end

    it "is transient so all definitions bubble up to parent context" do
      my_context = described_class.new

      my_context.register_variable!("x", 2)
      my_context.register_variable!("y", 7)
      my_context.register_function!("f", Proc.new {|x| x**2})
      my_context.register_function!("g", Proc.new {|x| x-1})

      expect(my_context.variable("x")).to eq 2
      expect(my_context.variable("y")).to eq 7
      expect(my_context.function("f").call(nil, 2)).to eq 4
      expect(my_context.function("g").call(nil, 2)).to eq 1

      child_context = my_context.spawn_child(transient: true)
      child_context.register_variable!("x", 5)
      child_context.register_function!("f", Proc.new {|x| x**3})
      Keisan::Calculator.new(context: child_context).evaluate("y = 11")
      Keisan::Calculator.new(context: child_context).evaluate("g(x) = 123*x")

      # Overriden by transient child!
      expect(my_context.variable("x")).to eq 5
      expect(my_context.variable("y")).to eq 11
      expect(my_context.function("f").call(nil, 2)).to eq 8
      expect(my_context.function("g").call(nil, 2)).to eq 246

      expect(child_context.variable("x")).to eq 5
      expect(child_context.variable("y")).to eq 11
      expect(child_context.function("f").call(nil, 2)).to eq 8
      expect(child_context.function("g").call(nil, 2)).to eq 246
    end
  end
end

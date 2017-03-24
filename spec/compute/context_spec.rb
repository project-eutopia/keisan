require "spec_helper"

RSpec.describe Compute::Context do
  it "contains function and variable registries" do
    my_context = described_class.new

    my_context.register_variable!("x", 2)
    my_context.register_function!("f", Proc.new {|x| x**2})
    expect(my_context.variable("x")).to eq 2
    expect(my_context.function("f").call(nil, 3)).to eq 9
  end

  it "has default variables and functions" do
    my_context = described_class.new

    expect(my_context.variable("pi")).to eq Math::PI
    expect(my_context.function("sin")).to be_a(Compute::Function)
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

      expect(child_context.variable("x")).to eq 5
      expect(child_context.variable("y")).to eq 7
      expect(child_context.function("f").call(nil, 2)).to eq 8
      expect(child_context.function("g").call(nil, 2)).to eq 1
    end
  end

  describe "random" do
    it "uses given Random object" do
      context1 = Compute::Context.new(random: Random.new(1234))
      context2 = Compute::Context.new(random: Random.new(1234))

      20.times do
        expect(context1.random.rand(100)).to eq context2.random.rand(100)
      end
    end

    it "uses parent random if does not have one" do
      rand1 = Random.new(2244)
      rand2 = Random.new(2244)

      parent = Compute::Context.new(random: rand1)
      child  = Compute::Context.new(parent: parent)

      20.times do
        expect(child.random.rand(100)).to eq rand2.rand(100)
      end
    end

    it "it shadows the parent random" do
      rand1 = Random.new(5151)
      rand1_copy = Random.new(5151)
      rand2 = Random.new(5959)

      parent = Compute::Context.new(random: rand1)
      child  = Compute::Context.new(parent: parent, random: rand2)

      matches = 20.times.map do |_|
        child.random.rand(100) == rand1_copy.rand(100)
      end

      expect(matches.any? {|bool| bool == false}).to be true
    end
  end
end
